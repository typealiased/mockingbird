import ArgumentParser
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import MockingbirdCommon
import MockingbirdGenerator
import PathKit
import ZIPFoundation

enum AssetBundleType: String, ExpressibleByArgument, CustomStringConvertible {
  case starterPack = "starter-pack"
  
  var description: String {
    switch self {
    case .starterPack: return "Starter supporting source files."
    }
  }
  
  var fileName: String {
    switch self {
    case .starterPack: return "MockingbirdSupport.zip"
    }
  }
  
  func getURL(template: String) -> URL? {
    return URL(string: template
      .replacingOccurrences(of: "<VERSION>", with: mockingbirdVersion.shortString)
      .replacingOccurrences(of: "<FILE>", with: fileName))
  }
}

struct Downloader {
  struct Configuration {
    let assetBundleType: AssetBundleType
    let outputPath: Path
    let urlTemplate: String
    let overwrite: Bool
    let urlSession: URLSession
    
    init(assetBundleType: AssetBundleType,
         outputPath: Path,
         urlTemplate: String,
         overwrite: Bool = false,
         urlSession: URLSession = URLSession(configuration: .ephemeral)) {
      self.assetBundleType = assetBundleType
      self.outputPath = outputPath
      self.urlTemplate = urlTemplate
      self.overwrite = overwrite
      self.urlSession = urlSession
    }
  }
  
  enum Error: LocalizedError {
    case validationFailed(_ message: String)
    case downloadFailed(_ message: String)
    case corruptBundle(_ message: String)
    
    var errorDescription: String? {
      switch self {
      case .validationFailed(let message),
           .downloadFailed(let message),
           .corruptBundle(let message):
        return message
      }
    }
  }
  
  enum Constants {
    static let excludedAssetRootDirectories: Set<String> = [
      "__MACOSX",
    ]
    static let excludedAssetFileNames: Set<String> = [
      ".DS_Store",
    ]
  }
  
  let config: Configuration
  
  init(config: Configuration) {
    self.config = config
  }
  
  func download() throws {
    guard let downloadURL = config.assetBundleType.getURL(template: config.urlTemplate) else {
      throw Error.validationFailed("Invalid URL template \(config.urlTemplate)")
    }
    switch downloadAssetBundle(at: downloadURL) {
    case .success(let fileURL):
      guard let archive = Archive(url: fileURL, accessMode: .read) else {
        throw Error.corruptBundle("Downloaded asset bundle is corrupt")
      }
      try extractAssetBundle(archive, to: config.outputPath)
    case .failure(let error):
      throw error
    }
  }
  
  private func downloadAssetBundle(at url: URL) -> Result<URL, Error> {
    let semaphore = DispatchSemaphore(value: 0)
    var result: Result<URL, Error>?
    config.urlSession.downloadTask(with: url) { (url, _, error) in
      if let fileURL = url {
        result = .success(fileURL)
      } else if let error = error {
        result = .failure(.downloadFailed(error.localizedDescription))
      } else {
        result = .failure(.downloadFailed("Missing path to downloaded asset bundle"))
      }
      semaphore.signal()
    }.resume()
    semaphore.wait()
    return result!
  }
  
  private func extractAssetBundle(_ archive: Archive, to path: Path) throws {
    let basePath = path.absolute()
    for entry in archive {
      let entryPath = Path(entry.path)
      guard
        let firstComponent = entryPath.components.first,
        !Constants.excludedAssetRootDirectories.contains(firstComponent)
      else {
        log("Skipping asset bundle entry due to excluded root directory at \(entryPath)")
        continue
      }
      guard !Constants.excludedAssetFileNames.contains(entryPath.lastComponent) else {
        log("Skipping asset bundle entry due to excluded file name at \(entryPath)")
        continue
      }
      
      let destinationPath = basePath + entryPath
      if destinationPath.exists {
        if !config.overwrite {
          log("Not overwriting existing contents at \(entryPath)")
          continue
        } else {
          log("Overwriting existing contents at \(entryPath)")
        }
      }
      
      _ = try archive.extract(entry, to: destinationPath.url)
    }
  }
}
