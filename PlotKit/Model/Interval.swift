//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation

/// Represents a closed interval in the real line
public struct Interval {
    public static let empty = Interval(min: DBL_MAX, max: DBL_MIN)

    public var min: Double
    public var max: Double

    public init() {
        min = DBL_MAX
        max = DBL_MIN
    }

    public init(min: Double, max: Double) {
        self.min = min
        self.max = max
    }

    /// Extract the minimum and maximum values from an array
    public init(values: [Double]) {
        self.init()
        for v in values {
            if v < min {
                min = v
            }
            if v > max {
                max = v
            }
        }
    }

    public func contains(value: Double) -> Bool {
        return min <= value && value <= max
    }
}

public func join(lhs: Interval, _ rhs: Interval) -> Interval {
    return Interval(min: min(lhs.min, rhs.min), max: max(lhs.max, rhs.max))
}

public func intersect(lhs: Interval, _ rhs: Interval) -> Interval {
    if lhs.max < rhs.min || rhs.max < lhs.min {
        return Interval.empty
    }
    return Interval(min: max(lhs.min, rhs.min), max: min(lhs.max, rhs.max))
}

/**
    Map a value from one interval to another. For instance mapping 0.5 from the interval [0, 1] to the iterval
    [1, 100] yields 50.
*/
func mapValue(value: Double, fromInterval: Interval, toInterval: Interval) -> Double {
    let parameter = (value - fromInterval.min) / (fromInterval.max - fromInterval.min)
    return toInterval.min + (toInterval.max - toInterval.min) * parameter
}
