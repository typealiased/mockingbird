//
//  String+Extensions.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

extension String {
  var capitalizedFirst: String {
    return prefix(1).capitalized + dropFirst()
  }
}
