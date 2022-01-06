import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableUndefinedArgumentLabels: UndefinedArgumentLabels, Mock {}
extension UndefinedArgumentLabelsMock: MockableUndefinedArgumentLabels {}
