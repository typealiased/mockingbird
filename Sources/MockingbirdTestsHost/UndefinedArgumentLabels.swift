//
//  UndefinedArgumentLabels.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/28/19.
//

import Foundation

protocol UndefinedArgumentLabels {
  func method(_: Bool, _: String, _ someParam: Int, _: Bool) -> Bool
}
