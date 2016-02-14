// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public enum PointType {
    case None
    case Ring(radius: Double)
    case Disk(radius: Double)
    case Square(side: Double)
    case FilledSquare(side: Double)
}

public struct Point {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public class PointSet {
    public var points: [Point]
    public var lineWidth = CGFloat(1.0)
    public var lineColor: NSColor? = NSColor.redColor()
    public var fillColor: NSColor? = nil
    public var pointColor: NSColor? = NSColor.redColor()
    public var pointType = PointType.None

    public var xInterval: ClosedInterval<Double> {
        let xValues = points.map{ $0.x }
        if xValues.isEmpty {
            return 0...0
        }
        return xValues.minElement()!...xValues.maxElement()!
    }
    public var yInterval: ClosedInterval<Double> {
        let yValues = points.map{ $0.y }
        if yValues.isEmpty {
            return 0...0
        }
        return yValues.minElement()!...yValues.maxElement()!
    }

    public init() {
        self.points = []
    }
    public init<T: SequenceType where T.Generator.Element == Point>(points: T) {
        self.points = [Point](points)
    }
    public init<T: SequenceType where T.Generator.Element == Double>(values: T) {
        self.points = values.enumerate().map{ Point(x: Double($0.0), y: $0.1) }
    }
}
