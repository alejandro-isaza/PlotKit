// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public func join<T>(lhs: ClosedInterval<T>, _ rhs: ClosedInterval<T>) -> ClosedInterval<T> {
    return min(lhs.start, rhs.start)...max(lhs.end, rhs.end)
}

public func intersect<T>(lhs: ClosedInterval<T>, _ rhs: ClosedInterval<T>) -> ClosedInterval<T>? {
    if lhs.end < rhs.start || rhs.end < lhs.start {
        return nil
    }
    return max(lhs.start, rhs.start)...min(lhs.end, rhs.end)
}

/**
    Map a value from one interval to another. For instance mapping 0.5 from the interval [0, 1] to the iterval
    [1, 100] yields 50.
*/
public func mapValue(value: Double, fromInterval: ClosedInterval<Double>, toInterval: ClosedInterval<Double>) -> Double {
    let parameter = (value - fromInterval.start) / (fromInterval.end - fromInterval.start)
    return toInterval.start + (toInterval.end - toInterval.start) * parameter
}
