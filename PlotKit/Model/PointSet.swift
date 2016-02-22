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
    public var points: [Point] {
        didSet {
            updateIntervals()
        }
    }
    public var lineWidth = CGFloat(1.0)
    public var lineColor: NSColor? = NSColor.redColor()
    public var fillColor: NSColor? = nil
    public var pointColor: NSColor? = NSColor.redColor()
    public var pointType = PointType.None

    public var xInterval = ClosedInterval<Double>(0, 0)
    public var yInterval = ClosedInterval<Double>(0, 0)

    public init() {
        self.points = []
    }
    public init<T: SequenceType where T.Generator.Element == Point>(points: T) {
        self.points = [Point](points)
        updateIntervals()
    }
    public init<T: SequenceType where T.Generator.Element == Double>(values: T) {
        self.points = values.enumerate().map{ Point(x: Double($0.0), y: $0.1) }
        updateIntervals()
    }

    func updateIntervals() {
        guard let first = points.first else {
            xInterval = 0...0
            yInterval = 0...0
            return
        }

        var minX = first.x
        var maxX = first.x
        var minY = first.y
        var maxY = first.y

        for p in points {
            if p.x < minX {
                minX = p.x
            }
            if p.x > maxX {
                maxX = p.x
            }
            if p.y < minY {
                minY = p.y
            }
            if p.y > maxY {
                maxY = p.y
            }
        }

        xInterval = minX...maxX
        yInterval = minY...maxY
    }
}
