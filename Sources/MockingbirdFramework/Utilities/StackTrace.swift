import Foundation

struct StackTrace {
  let callStackSymbols: [String]
  
  init(from callStackSymbols: [String]) {
    self.callStackSymbols = callStackSymbols
  }
  
  struct Frame {
    let location: String
    let frameAddress: String // Hex formatted address
    let symbol: String
  }
  
  func parseFrames() -> [Frame] {
    let symbolOptions = SymbolPrintOptions.default.union(.synthesizeSugarOnTypes)
    let regexPattern = #"[0-9]+\s+(\S+)\s+(\S+) (.*) \+ [0-9]+"#
    return callStackSymbols.compactMap({ frame -> Frame? in
      guard
        let components = frame.components(matching: regexPattern).first, components.count == 4,
        let location = components.get(1),
        let frameAddress = components.get(2),
        let mangledSymbol = components.get(3)
      else { return nil }
      
      let demangledSymbol: String
      if let parsedSymbol = try? parseMangledSwiftSymbol(String(mangledSymbol)) {
        demangledSymbol = parsedSymbol.print(using: symbolOptions)
      } else {
        demangledSymbol = String(mangledSymbol) // This is probably an Objective-C symbol.
      }
      
      return Frame(location: String(location),
                   frameAddress: String(frameAddress),
                   symbol: demangledSymbol)
    })
  }
}
