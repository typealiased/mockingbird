//
//  DownloadCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 4/26/20.
//

import Foundation
import MockingbirdGenerator
import PathKit
import SPMUtility
import ZIPFoundation

enum AssetBundleType: String, ArgumentKind, CaseIterable, CustomStringConvertible {
  case starterPack = "starter-pack"
  
  init(argument: String) throws {
    guard AssetBundleType(rawValue: argument) != nil else {
      let allOptions = AssetBundleType.allCases.map({ $0.rawValue }).joined(separator: ", ")
      throw ArgumentParserError.invalidValue(
        argument: "asset",
        error: .custom("\(argument.singleQuoted) is not a valid download type, expected: \(allOptions)")
      )
    }
    self.init(rawValue: argument)!
  }
  
  static var completion: ShellCompletion {
    return .values(AssetBundleType.allCases.map({
      (value: $0.rawValue, description: "\($0)")
    }))
  }
  
  var description: String {
    switch self {
    case .starterPack: return "Starter supporting source files."
    }
  }
  
  func getUrl(with baseUrl: String) -> Foundation.URL {
    let fileName: String
    switch self {
    case .starterPack: fileName = "MockingbirdSupport.zip"
    }
    return Foundation.URL(string:
      "\(baseUrl)/\(mockingbirdVersion)/\(fileName)"
    )!
  }
}

final class DownloadCommand: BaseCommand {
  private enum Constants {
    static let name = "download"
    static let overview = "Download and unpack a compatible asset bundle."
    
    static let excludedAssetRootDirectories: Set<String> = [
      "__MACOSX",
    ]
    static let excludedAssetFileNames: Set<String> = [
      ".DS_Store",
    ]
    
    static let defaultBaseUrl = "https://github.com/birdrides/mockingbird/releases/download"
  }
  override var name: String { return Constants.name }
  override var overview: String { return Constants.overview }
  
  private let assetBundleTypeArgument: PositionalArgument<AssetBundleType>
  private let projectPathArgument: OptionArgument<PathArgument>
  private let baseUrlArgument: OptionArgument<String>
  
  required init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: Constants.name, overview: Constants.overview)
    self.assetBundleTypeArgument = subparser.addAssetBundleType()
    self.projectPathArgument = subparser.addProjectPath()
    self.baseUrlArgument = subparser.addBaseUrl()
    super.init(parser: subparser)
  }
  
  override func run(with arguments: ArgumentParser.Result,
                    environment: [String: String],
                    workingPath: Path) throws {
    let projectPath = try arguments.getProjectPath(using: projectPathArgument,
                                                   environment: environment,
                                                   workingPath: workingPath)
    let inferredRootPath = projectPath.parent()
    let baseUrl = arguments.get(baseUrlArgument) ?? Constants.defaultBaseUrl
    
    try super.run(with: arguments, environment: environment, workingPath: workingPath)
    guard let type = arguments.get(assetBundleTypeArgument) else { return }
    
    let downloadUrl = type.getUrl(with: baseUrl)
    logInfo("Downloading asset bundle from \(downloadUrl)")
    guard let fileUrl = downloadAssetBundle(downloadUrl) else {
      log("Unable to download asset bundle \(type.rawValue.singleQuoted)", type: .error)
      exit(1)
    }
    
    logInfo("Temporary asset bundle data stored at \(fileUrl)")
    logInfo("Extracting downloaded asset bundle to \(Path().absolute())")
    guard let archive = Archive(url: fileUrl, accessMode: .read) else {
      log("The downloaded asset bundle is corrupted", type: .error)
      exit(1)
    }
    
    try self.extractAssetBundle(archive, to: inferredRootPath)
    logInfo("Successfully loaded asset bundle \(type.rawValue.singleQuoted) into \(inferredRootPath)")
  }
  
  private func downloadAssetBundle(_ url: Foundation.URL) -> Foundation.URL? {
    let semaphore = DispatchSemaphore(value: 0)
    var fileUrl: Foundation.URL?
    URLSession.shared.downloadTask(with: url) { (url, _, error) in
      if let error = error { log(error) }
      fileUrl = url
      semaphore.signal()
    }.resume()
    semaphore.wait()
    return fileUrl
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
      guard !destinationPath.exists else {
        logWarning("Skipping existing asset bundle contents at \(entryPath)")
        continue
      }
      _ = try archive.extract(entry, to: destinationPath.url)
    }
  }
}
