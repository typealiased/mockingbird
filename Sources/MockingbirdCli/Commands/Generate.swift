import ArgumentParser
import Foundation
import MockingbirdGenerator
import PathKit

extension Mockingbird {
  struct Generate: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Generate mocks for a set of targets in a project."
    )
    
    /// Inherited from parent command.
    @OptionGroup() var globalOptions: Options
    
    @Option(name: [.customLong("targets"),
                   .customLong("target"),
                   .customShort("t")],
            parsing: .upToNextOption,
            help: "List of target names to generate mocks for.")
    var targets: [String] // TODO: This will be optional in generator v2
    
    @Option(name: [.customLong("project"),
                   .customShort("p")],
            help: "Path to an Xcode project or a JSON project description.")
    var project: XcodeProjPath?
    
    @Option(help: "The directory containing your project’s source files.")
    var srcroot: DirectoryPath? // TODO: This will be deprecated in generator v2
    
    @Option(name: [.customLong("outputs"),
                   .customLong("output"),
                   .customShort("o")],
            parsing: .upToNextOption,
            help: "List of output file paths corresponding to each target.")
    var outputs: [SwiftFilePath] = [] // TODO: This will be optional in generator v2
    
    @Option(help: "The directory where generated files should be output.")
    var outputDir: DirectoryPath?
    
    @Option(help: "The directory containing supporting source files.")
    var support: DirectoryPath?
    
    @Option(help: "The name of the test bundle using the mocks.")
    var testbundle: TestBundleName?
    
    @Option(parsing: .upToNextOption,
            help: "Lines to show at the top of generated mock files.")
    var header: [String] = []
    
    @Option(help: "Compilation condition to wrap all generated mocks in.")
    var condition: String?
    
    @Option(parsing: .upToNextOption,
            help: "List of diagnostic generator warnings to enable.")
    var diagnostics: [DiagnosticType] = []
    
    @Option(help: "The thunk pruning level for unreferenced types.")
    var prune: PruningMethod?
    
    // MARK: Flags
    
    @Flag(help: "Only generate mocks for protocols.")
    var onlyProtocols: Bool = false
    
    @Flag(help: "Disable all SwiftLint rules in generated mocks.")
    var disableSwiftlint: Bool = false
    
    @Flag(help: "Ignore cached mock information stored on disk.")
    var disableCache: Bool = false
    
    @Flag(help: "Only search explicitly imported modules.")
    var disableRelaxedLinking: Bool = false
    
    struct Arguments {
      let targets: [String]
      let project: Path
      let srcroot: Path
      let outputs: [Path]
      let outputDir: Path?
      let support: Path
      let testbundle: String?
      let header: [String]
      let condition: String?
      let diagnostics: [DiagnosticType]
      let prune: PruningMethod?

      let environmentProjectFilePath: Path?
      let environmentSourceRoot: Path?
      let environmentTargetName: String?
      
      let onlyProtocols: Bool
      let disableSwiftlint: Bool
      let disableCache: Bool
      let disableRelaxedLinking: Bool
    }
    
    func validate() throws {
      try infer()
    }
    
    @discardableResult
    nonmutating func infer(context: ArgumentContext = .shared) throws -> Arguments {
      let validProject = try validateRequiredArgument(inferArgument(project, in: context),
                                                      name: "project")
      let validSrcroot = try validateRequiredArgument(
        srcroot ?? DirectoryPath(path: validProject.path.parent()), name: "srcroot")
      let validTestBundle = try validateOptionalArgument(inferArgument(testbundle, in: context),
                                                         name: "testbundle")
      let validSupportPath = support?.path ?? (validSrcroot.path + "MockingbirdSupport")
      
      let environment = ArgumentContext.shared.environment
      let environmentProjectFilePath: Path? = {
        guard validProject.path.extension == "xcodeproj" else { return validProject.path }
        guard let filePath = environment["PROJECT_FILE_PATH"] else { return nil }
        let path = Path(filePath)
        guard path.extension == "xcodeproj" else { return nil }
        return path
      }()
      let environmentSourceRoot: Path? = {
        guard validProject.path.extension == "xcodeproj" else { return validProject.path.parent() }
        guard let sourceRoot = environment["SRCROOT"] ?? environment["SOURCE_ROOT"] else {
          return nil
        }
        return Path(sourceRoot)
      }()
      let environmentTargetName: String? = validTestBundle?.name
        ?? environment["TARGET_NAME"]
        ?? environment["TARGETNAME"]
      
      return Arguments(
        targets: targets,
        project: validProject.path,
        srcroot: validSrcroot.path,
        outputs: outputs.map({ $0.path }),
        outputDir: outputDir?.path, // Managed by the generator.
        support: validSupportPath,
        testbundle: validTestBundle?.name,
        header: header,
        condition: condition,
        diagnostics: diagnostics,
        prune: prune,

        environmentProjectFilePath: environmentProjectFilePath,
        environmentSourceRoot: environmentSourceRoot,
        environmentTargetName: environmentTargetName,
        
        onlyProtocols: onlyProtocols,
        disableSwiftlint: disableSwiftlint,
        disableCache: disableCache,
        disableRelaxedLinking: disableRelaxedLinking
      )
    }
    
    func run() throws {
      let arguments = try infer()
      let config = Generator.Configuration(
        projectPath: arguments.project,
        sourceRoot: arguments.srcroot,
        inputTargetNames: arguments.targets,
        environmentProjectFilePath: arguments.environmentProjectFilePath,
        environmentSourceRoot: arguments.environmentSourceRoot,
        environmentTargetName: arguments.environmentTargetName,
        outputPaths: arguments.outputs,
        outputDir: arguments.outputDir,
        supportPath: arguments.support,
        header: arguments.header,
        compilationCondition: arguments.condition,
        pruningMethod: arguments.prune ?? .omit,
        onlyMockProtocols: arguments.onlyProtocols,
        disableSwiftlint: arguments.disableSwiftlint,
        disableCache: arguments.disableCache,
        disableRelaxedLinking: arguments.disableRelaxedLinking
      )
      try Generator(config).generate()
    }
  }
}

extension Mockingbird.Generate: EncodableArguments {
  // Keep in sync with the options and flags declared in `Mockingbird.Generate`.
  enum CodingKeys: String, CodingKey {
    // Options
    case globalOptions
    case targets
    case project
    case srcroot
    case outputs
    case outputDir
    case support
    case testbundle
    case header
    case condition
    case diagnostics
    case prune
    
    // Flags
    case onlyProtocols
    case disableSwiftlint
    case disableCache
    case disableRelaxedLinking
  }
  
  func encode(to encoder: Encoder) throws {
    try encodeOptions(to: encoder)
    try encodeFlags(to: encoder)
    try encodeOptionGroups(to: encoder)
  }
  
  func encodeOptions(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(targets, forKey: .targets)
    try container.encode(project, forKey: .project)
    try container.encode(srcroot, forKey: .srcroot)
    try container.encode(outputs, forKey: .outputs)
    try container.encode(outputDir, forKey: .outputDir)
    try container.encode(support, forKey: .support)
    try container.encode(testbundle, forKey: .testbundle)
    try container.encode(header, forKey: .header)
    try container.encode(condition, forKey: .condition)
    try container.encode(diagnostics, forKey: .diagnostics)
    try container.encode(prune, forKey: .prune)
  }
  
  func encodeFlags(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(onlyProtocols, forKey: .onlyProtocols)
    try container.encode(disableSwiftlint, forKey: .disableSwiftlint)
    try container.encode(disableCache, forKey: .disableCache)
    try container.encode(disableRelaxedLinking, forKey: .disableRelaxedLinking)
  }
  
  func encodeOptionGroups(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(globalOptions, forKey: .globalOptions)
  }
}
