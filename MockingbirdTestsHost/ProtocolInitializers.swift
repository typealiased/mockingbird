//
//  ProtocolInitializers.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/25/19.
//

import Foundation

protocol NoInitializerProtocol {}

protocol EmptyInitializerProtocol {
  init()
}

protocol ParameterizedInitializerProtocol {
  init(param1: Bool, param2: Int)
}
