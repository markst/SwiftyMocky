//
//  Parameter.swift
//  Pods
//
//  Created by przemyslaw.wosko on 19/05/2017.
//
//

import Foundation

public class Matcher {
    public static var `default` = Matcher()

    var matchers: [(Mirror,Any)] = []

    public init() {
    }

    public func register<T>(_ valueType: T.Type, match: @escaping (T,T) -> Bool) {
        let mirror = Mirror(reflecting: valueType)
        matchers.append((mirror, match as Any))
    }

    public func comparator<T>(for valueType: T.Type) -> ((T,T) -> Bool)? {
        let mirror = Mirror(reflecting: valueType)

        let comparator = matchers.reversed().first { (current, _) -> Bool in
            return current.subjectType == mirror.subjectType
        }?.1

        print(comparator)

        return comparator as! (T,T) -> Bool
    }
}

public enum Parameter<ValueType> {
    case any
    case value(ValueType)
    
    public static func ==(lhs: Parameter<ValueType>, rhs: Parameter<ValueType>) -> Bool {
        print("Parameter not equatable")
        switch (lhs, rhs) {
        default: return true
        }
    }

    public static func compare(lhs: Parameter<ValueType>, rhs: Parameter<ValueType>, with matcher: Matcher) -> Bool {
        print("Parameter not equatable")
        switch (lhs, rhs) {
        case (.any, _): return true
        case (_, .any): return true
        case (.value(let lhsValue), .value(let rhsValue)):
            guard let compare = matcher.comparator(for: ValueType.self) else {
                fatalError("No registered comparators for \(String(describing: ValueType.self))")
            }
            return compare(lhsValue,rhsValue)
        default: return true
        }
    }
}

public extension Parameter where ValueType : Sequence {
    
    public static func ==<ValueType: Equatable>(lhs: Parameter<ValueType>, rhs: Parameter<ValueType>) -> Bool {
        print("Parameter is sequence")
        switch (lhs, rhs) {
        case (.any, _): return true
        case (_, .any): return true
        case (.value(let lhsSequence), .value(let rhsSequence)):
            return lhsSequence == rhsSequence
        default: return false
        }
    }

    public static func compare<ValueType: Equatable>(lhs: Parameter<ValueType>, rhs: Parameter<ValueType>, with matcher: Matcher) -> Bool {
        return lhs == rhs
    }
}

public extension Parameter where ValueType: Equatable {
    
    public static func ==(lhs: Parameter<ValueType>, rhs: Parameter<ValueType>) -> Bool {
        print("Parameter is equatable")
        switch (lhs, rhs) {
        case (.any, _): return true
        case (_, .any): return true
        case (.value(let value1), .value(let value2)):
            return value1 == value2
        default: return false
        }
    }

    public static func compare(lhs: Parameter<ValueType>, rhs: Parameter<ValueType>, with matcher: Matcher) -> Bool {
        return lhs == rhs
    }
}
