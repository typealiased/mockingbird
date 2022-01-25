import Foundation
import PathKit

public struct GenerateFileConfig {
  let moduleName: String
  let testTargetName: String?
  let outputPath: Path
  let header: [String]
  let compilationCondition: String?
  let onlyMockProtocols: Bool
  let disableSwiftlint: Bool
  let pruningMethod: PruningMethod
  
  public init(moduleName: String,
              testTargetName: String?,
              outputPath: Path,
              header: [String],
              compilationCondition: String?,
              onlyMockProtocols: Bool,
              disableSwiftlint: Bool,
              pruningMethod: PruningMethod) {
    self.moduleName = moduleName
    self.testTargetName = testTargetName
    self.outputPath = outputPath
    self.header = header
    self.compilationCondition = compilationCondition
    self.onlyMockProtocols = onlyMockProtocols
    self.disableSwiftlint = disableSwiftlint
    self.pruningMethod = pruningMethod
  }
}

public class GenerateFileOperation: Runnable {
  let processTypesResult: ProcessTypesOperation.Result
  let checkCacheResult: CheckCacheOperation.Result?
  let findMockedTypesResult: FindMockedTypesOperation.Result?
  let config: GenerateFileConfig
  
  public var description: String { "Generate File" }
  public let id = UUID()
  
  public init(processTypesResult: ProcessTypesOperation.Result,
              checkCacheResult: CheckCacheOperation.Result?,
              findMockedTypesResult: FindMockedTypesOperation.Result?,
              config: GenerateFileConfig) {
    self.processTypesResult = processTypesResult
    self.checkCacheResult = checkCacheResult
    self.findMockedTypesResult = findMockedTypesResult
    self.config = config
  }
  
  public func run(context: RunnableContext) throws {
    guard checkCacheResult?.isCached != true else { return }
    var contents: PartialFileContent!
    time(.renderMocks) {
      let generator = FileGenerator(
        mockableTypes: processTypesResult.mockableTypes,
        mockedTypeNames: findMockedTypesResult?.allMockedTypeNames,
        parsedFiles: processTypesResult.parsedFiles,
        config: config
      )
      contents = generator.generate(context: context)
    }
    
    try time(.writeFiles) {
      try config.outputPath.writeUtf8Strings(contents)
    }
    
    logInfo("Generated file to \(config.outputPath.absolute())")
  }
}
