import ArgumentParser
import Foundation
import MockingbirdAutomation
import PathKit

extension Build {
  struct BuildDocumentation: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "docs",
      abstract: "Build a documentation archive using DocC.")
    
    @Option(help: "Path to the documentation bundle directory.")
    var bundle: String = "./Sources/Mockingbird.docc"
    
    @Option(help: "Path to a documentation renderer.")
    var renderer: String = "./Sources/Mockingbird.docc/Renderer"
    
    @OptionGroup()
    var globalOptions: Options
    
    func run() throws {
      let symbolGraphs = Path("./.build/symbol-graphs")
      try symbolGraphs.mkpath()
      try SwiftPackage.emitSymbolGraph(target: .target(name: "Mockingbird"),
                                       packageConfiguration: .libraries,
                                       output: symbolGraphs,
                                       package: Path("./Package.swift"))
      
      let filteredSymbolGraphs = Path("./.build/mockingbird-symbol-graphs")
      try? filteredSymbolGraphs.delete()
      try filteredSymbolGraphs.mkpath()
      
      let mockingbirdSymbolGraphs = symbolGraphs.glob("Mockingbird@*.symbols.json")
        + [symbolGraphs + "Mockingbird.symbols.json"]
      try mockingbirdSymbolGraphs.forEach({ try $0.copy(filteredSymbolGraphs + $0.lastComponent) })
      
      let bundlePath = Path(bundle)
      if let location = globalOptions.archiveLocation {
        let outputPath = Path("./.build/mockingbird/artifacts/Mockingbird.doccarchive")
        try outputPath.parent().mkpath()
        try? outputPath.delete()
        try DocC.convert(bundle: bundlePath,
                         symbolGraph: filteredSymbolGraphs,
                         renderer: Path(renderer),
                         output: outputPath)
        try archive(artifacts: [("", outputPath)], destination: Path(location))
      } else {
        try DocC.preview(bundle: bundlePath,
                         symbolGraph: filteredSymbolGraphs,
                         renderer: Path(renderer))
      }
    }
  }
}
