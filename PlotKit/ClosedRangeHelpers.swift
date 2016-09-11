// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public func join<T>(_ lhs: ClosedRange<T>, _ rhs: ClosedRange<T>) -> ClosedRange<T> {
    return min(lhs.lowerBound, rhs.lowerBound)...max(lhs.upperBound, rhs.upperBound)
}

public func intersect<T>(_ lhs: ClosedRange<T>, _ rhs: ClosedRange<T>) -> ClosedRange<T>? {
    if lhs.upperBound < rhs.lowerBound || rhs.upperBound < lhs.lowerBound {
        return nil
    }
    return max(lhs.lowerBound, rhs.lowerBound)...min(lhs.upperBound, rhs.upperBound)
}

/**
    Map a value from one interval to another. For instance mapping 0.5 from the interval [0, 1] to the iterval
    [1, 100] yields 50.
*/
public func mapValue(_ value: Double, fromInterval: ClosedRange<Double>, toInterval: ClosedRange<Double>) -> Double {
    let parameter = (value - fromInterval.lowerBound) / (fromInterval.upperBound - fromInterval.lowerBound)
    return toInterval.lowerBound + (toInterval.upperBound - toInterval.lowerBound) * parameter
}
