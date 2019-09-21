//
//  Generics.swift
//  MockingbirdModuleTestsHost
//
//  Created by Andrew Chang on 9/21/19.
//

import Foundation

public class ReferencedGenericClass<T> {}
public class ReferencedGenericClassWithConstraints<S: Sequence> where S.Element: Hashable {}
