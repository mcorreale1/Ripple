//
//  ORCommon.swift
//  Pods
//
//  Created by Maxim Soloviev on 10/09/16.
//
//

import Foundation

public func NSLS(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

public func or_typeToString<T>(type: T.Type) -> String {
    return String(type)
}

public func or_instanceTypeToString(instance: Any) -> String {
    let s = String(instance.dynamicType).componentsSeparatedByString(".").last!
    return s
}

public func or_safeString(str: String?) -> String {
    return str ?? ""
}
