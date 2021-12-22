//
//  Downloader.swift
//  MockingbirdCli
//
//  Created by typealias on 8/8/21.
//

import ArgumentParser
import Foundation
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
  
  func getURL(baseURL: String) -> URL? {
    let fileName: String = {
      switch self {
      case .starterPack: return "MockingbirdSupport.zip"
      }
    }()
    return URL(string: "\(baseURL)/\(mockingbirdVersion)/\(fileName)")
  }
}

struct Downloader {
  struct Configuration {
    let assetBundleType: AssetBundleType
    let outputPath: Path
    let baseURL: String
    let overwrite: Bool
    let urlSession: URLSession
    
    init(assetBundleType: AssetBundleType,
         outputPath: Path,
         baseURL: String,
         overwrite: Bool = false,
         urlSession: URLSession = URLSession(configuration: .ephemeral)) {
      self.assetBundleType = assetBundleType
      self.outputPath = outputPath
      self.baseURL = baseURL
      self.overwrite = overwrite
      self.urlSession = urlSession
    }
  }
  
  enum Failure: LocalizedError {
    case validationError(_ message: String)
    case unableToDownload(_ message: String)
    case corruptBundle(_ message: String)
    
    var errorDescription: String? {
      switch self {
      case .validationError(let message),
           .unableToDownload(let message),
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
    guard let downloadURL = config.assetBundleType.getURL(baseURL: config.baseURL) else {
      throw Failure.validationError("Invalid base URL \(config.baseURL)")
    }
    switch downloadAssetBundle(at: downloadURL) {
    case .success(let fileURL):
      guard let archive = Archive(url: fileURL, accessMode: .read) else {
        throw Failure.corruptBundle("Downloaded asset bundle is corrupt")
      }
      try extractAssetBundle(archive, to: config.outputPath)
    case .failure(let error):
      throw error
    }
  }
  
  private func downloadAssetBundle(at url: URL) -> Result<URL, Failure> {
    let semaphore = DispatchSemaphore(value: 0)
    var result: Result<URL, Failure>?
    config.urlSession.downloadTask(with: url) { (url, _, error) in
      if let fileURL = url {
        result = .success(fileURL)
      } else if let error = error {
        result = .failure(Failure.unableToDownload(error.localizedDescription))
      } else {
        result = .failure(Failure.unableToDownload("Missing path to downloaded asset bundle"))
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
        log("Skipping excluded asset bundle entry based on root directory at \(entryPath)")
        continue
      }
      guard !Constants.excludedAssetFileNames.contains(entryPath.lastComponent) else {
        log("Skipping excluded asset bundle entry based on file name at \(entryPath)")
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
