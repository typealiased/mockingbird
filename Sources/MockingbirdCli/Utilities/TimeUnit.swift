//
//  TimeInterval+Normalize.swift
//  MockingbirdCli
//
//  Created by typealias on 8/8/21.
//

import Foundation

enum TimeUnit: CustomStringConvertible {
  case millisecond(Double), second(Double), minute(Double)
  
  init(_ delta: TimeInterval) {
    if delta < 1 {
      self = .millisecond(delta*1000)
    } else if delta < 60 {
      self = .second(delta)
    } else {
      self = .minute(delta/60)
    }
  }
  
  var description: String {
    format(to: 0)
  }
  
  func format(to digits: Int) -> String {
    let normalize = { (value: Double) -> String in
      guard digits > 0 else {
        return String(Int(value))
      }
      let precision = pow(10, Double(digits))
      return String(round(value * precision) / precision)
    }
    switch self {
    case .millisecond(let value): return "\(normalize(value))ms"
    case .second(let value): return "\(normalize(value))s"
    case .minute(let value): return "\(normalize(value))m"
    }
  }
}
