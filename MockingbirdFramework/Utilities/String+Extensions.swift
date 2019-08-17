//
//  String+Extensions.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

extension String {
  static func describe(_ subject: Any?) -> String {
    guard let subject = subject else { return "nil" }
    return String(describing: subject)
  }
}
