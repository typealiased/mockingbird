//
//  Collections.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/6/19.
//

import Foundation

protocol ArrayCollection {
  func method(objects: [String]) -> Bool
}

protocol DictionaryCollection {
  func method(objects: [String: String]) -> Bool
}
