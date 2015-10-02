//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation

public struct Point : Equatable {
    public var x: Double
    public var y: Double

    public init() {
        x = 0.0
        y = 0.0
    }
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

public func distance(lhs: Point, _ rhs: Point) -> Double {
    return sqrt(distanceSq(lhs, rhs))
}

public func distanceSq(lhs: Point, _ rhs: Point) -> Double {
    let dx = rhs.x - lhs.x
    let dy = rhs.y - lhs.y
    return dx*dx + dy*dy
}

extension Point : Hashable {
    public var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
}
