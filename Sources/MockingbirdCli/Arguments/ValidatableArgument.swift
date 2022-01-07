//
//  ValidatableArgument.swift
//  MockingbirdCli
//
//  Created by typealias on 8/7/21.
//

import ArgumentParser
import Foundation

protocol ValidatableArgument {
  func validate(name: String) throws
}

@discardableResult
func validateRequiredArgument<T>(_ argument: T?, name: String) throws -> T {
  guard let validatedArgument = try argument ??
          validateOptionalArgument(argument, name: name) else {
    if argument is InferableArgument {
      throw ValidationError("Unable to infer a value for '\(name)'")
    } else {
      throw ValidationError("Missing required value for '\(name)'")
    }
  }
  return validatedArgument
}

@discardableResult
func validateOptionalArgument<T>(_ argument: T?, name: String) throws -> T? {
  if let validatableArgument = argument as? ValidatableArgument {
    try validatableArgument.validate(name: name)
  }
  return argument
}
