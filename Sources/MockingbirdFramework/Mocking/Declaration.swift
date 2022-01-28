import Foundation

/// All mockable declaration types conform to this protocol.
public protocol Declaration {}

/// Mockable declarations.
public class AnyDeclaration: Declaration {}

/// Mockable variable declarations.
public class VariableDeclaration: Declaration {}
/// Mockable property getter declarations.
public class PropertyGetterDeclaration: VariableDeclaration {}
/// Mockable property setter declarations.
public class PropertySetterDeclaration: VariableDeclaration {}

/// Mockable function declarations.
public class FunctionDeclaration: Declaration {}
/// Mockable async function declarations.
public class AsyncFunctionDeclaration: FunctionDeclaration {}
/// Mockable throwing function declarations.
public class ThrowingFunctionDeclaration: FunctionDeclaration {}
/// Mockable throwing async function declarations.
public class ThrowingAsyncFunctionDeclaration: AsyncFunctionDeclaration {}

/// Mockable subscript declarations.
public class SubscriptDeclaration: Declaration {}
/// Mockable subscript getter declarations.
public class SubscriptGetterDeclaration: SubscriptDeclaration {}
/// Mockable subscript setter declarations.
public class SubscriptSetterDeclaration: SubscriptDeclaration {}

/// All mockable declarations conform to this protocol.
public protocol AnyMockable {}

/// Represents a mocked declaration that can be stubbed or verified.
public struct Mockable<DeclarationType: Declaration, InvocationType, ReturnType>: AnyMockable {
  let context: Context
  let invocation: Invocation
}
