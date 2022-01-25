import Foundation
import PathKit
import SourceKittenFramework
import SwiftSyntax

public class ParseFilesOperation: Runnable {
  let extractSourcesResult: ExtractSourcesOperationResult
  let checkCacheResult: CheckCacheOperation.Result?
  
  public class Result {
    fileprivate(set) var parsedFiles = [ParsedFile]()
    fileprivate(set) var moduleDependencies = [String: Set<String>]()
  }
  
  public let result = Result()
  public var description: String { "Parse Files" }
  
  public init(extractSourcesResult: ExtractSourcesOperationResult,
              checkCacheResult: CheckCacheOperation.Result?) {
    self.extractSourcesResult = extractSourcesResult
    self.checkCacheResult = checkCacheResult
  }
  
  public func run(context: RunnableContext) throws {
    time(.parseFiles) {
      guard checkCacheResult?.isCached != true else { return }
      
      let sourceOperations = extractSourcesResult.targetPaths.map({ path in
        createOperations(path: path, shouldMock: true, context: context)
      })
      let dependencyOperations = extractSourcesResult.dependencyPaths.map({ path in
        createOperations(path: path, shouldMock: false, context: context)
      })
      let operations = sourceOperations + dependencyOperations
      context.runAndWait(for: operations)
      result.parsedFiles = operations.compactMap({ $0.result.parsedFile })
    }
    
    result.moduleDependencies = extractSourcesResult.moduleDependencies
  }
  
  func createOperations(path: SourcePath,
                        shouldMock: Bool,
                        context: RunnableContext) -> ParseSingleFileOperation {
    let parseSourceKit = ParseSourceKitOperation(sourcePath: path)
    let parseSwiftSyntax = ParseSwiftSyntaxOperation(sourcePath: path)
    let parseSingleFile = ParseSingleFileOperation(sourcePath: path,
                                                   shouldMock: shouldMock,
                                                   sourceKitResult: parseSourceKit.result,
                                                   swiftSyntaxResult: parseSwiftSyntax.result)
    
    retainForever(parseSourceKit)
    retainForever(parseSwiftSyntax)
    retainForever(parseSingleFile)
    
    context.registerChild(parseSingleFile, dependencies: [parseSourceKit, parseSwiftSyntax])
    return parseSingleFile
  }
}
