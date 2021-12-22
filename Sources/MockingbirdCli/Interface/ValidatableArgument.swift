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
func validateRequiredArgument<T: ValidatableArgument>(_ argument: T?, name: String) throws -> T? {
  guard argument != nil else {
    if argument is InferableArgument {
      throw ValidationError("Unable to infer a value for '\(name)'")
    } else {
      throw ValidationError("Missing required value for '\(name)'")
    }
  }
  return try validateOptionalArgument(argument, name: name)
}

@discardableResult
func validateOptionalArgument<T: ValidatableArgument>(_ argument: T?, name: String) throws -> T? {
  try argument?.validate(name: name)
  return argument
}
