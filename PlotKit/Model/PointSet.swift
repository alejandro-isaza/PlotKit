//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation

import Surge

public enum PointType {
    case None
    case Ring(radius: Double)
    case Disk(radius: Double)
    case Square(side: Double)
    case FilledSquare(side: Double)
}

public typealias Point = Surge.Point<Double>

public class PointSet {
    public var points: [Point]
    public var lines = true
    public var lineWidth = CGFloat(1.0)
    public var color = NSColor.redColor()
    public var pointType = PointType.None

    public var xInterval: Interval {
        return Interval(values: points.map{ $0.x })
    }
    public var yInterval: Interval {
        return Interval(values: points.map{ $0.y })
    }

    public init() {
        self.points = []
    }
    public init(points: [Point]) {
        self.points = points
    }
    public init(values: [Double]) {
        var i = 0
        self.points = values.map{ Point(x: Double(i++), y: $0) }
    }
}
