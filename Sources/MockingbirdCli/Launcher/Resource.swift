//
//  Resource.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 4/25/20.
//

import Foundation

struct Resource {
  let encodedData: String
  let fileName: String
  var data: Data { return Data(base64Encoded: encodedData)! }
}
