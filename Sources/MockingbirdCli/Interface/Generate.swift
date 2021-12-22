//
//  Generate.swift
//  MockingbirdCli
//
//  Created by typealias on 8/8/21.
//

import ArgumentParser
import Foundation
import MockingbirdGenerator
import PathKit

extension Mockingbird {
  struct Generate: ParsableCommand {
    @Option(help: "List of target names to generate mocks for.")
    var targets: [String] // TODO: This will be optional for generator v2
    
    @Option(help: "Path to a Xcode project or a JSON project description.")
    var project: XcodeProjPath?
    
    @Option(help: "The directory containing your project’s source files.")
    var srcroot: DirectoryPath?
    
    @Option(help: "List of mock output file paths for each target.",
            transform: Path.init(stringLiteral:))
    var outputs: [Path] = [] // TODO: This will be optional for generator v2
    
    @Option(help: "The directory containing supporting source files.")
    var support: SupportingSourcesPath?
    
    @Option(help: "The name of the test bundle using the mocks.")
    var testbundle: String? // TODO
    
    @Option(help: "Content to add at the beginning of each generated mock file.")
    var header: [String] = []
    
    @Option(help: "Compilation condition to wrap all generated mocks in, e.g. 'DEBUG'.")
    var condition: String?
    
    @Option(help: "List of diagnostic generator warnings to enable.")
    var diagnostics: [DiagnosticType] = []
    
    @Option(help: "The pruning method to use on unreferenced types.")
    var prune: PruningMethod = .omit
    
    // MARK: Flags
    
    @Flag(help: "Only generate mocks for protocols.")
    var onlyProtocols: Bool = false
    
    @Flag(help: "Disable all SwiftLint rules in generated mocks.")
    var disableSwiftlint: Bool = false
    
    @Flag(help: "Ignore cached mock information stored on disk.")
    var disableCache: Bool = false
    
    @Flag(help: "Only search explicitly imported modules.")
    var disableRelaxedLinking: Bool = false
    
    mutating func validate() throws {
      try validateRequiredArgument(inferArgument(&project), name: "project")
      try validateOptionalArgument(inferArgument(&support), name: "support")
      
      srcroot = srcroot ?? DirectoryPath(path: project?.path.parent())
      try validateRequiredArgument(srcroot, name: "srcroot")
    }
    
    // TODO: Hook into generator pipeline
  }
}
