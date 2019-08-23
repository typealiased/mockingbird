//
//  DateFormatter+Extensions.swift
//  MockingbirdShared
//
//  Created by Andrew Chang on 8/23/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

extension DateFormatter {
  public static func standard() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zz"
    return formatter
  }
}
