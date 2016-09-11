// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public enum PointType {
    case none
    case ring(radius: Double)
    case disk(radius: Double)
    case square(side: Double)
    case filledSquare(side: Double)
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
    public var lineColor: NSColor? = NSColor.red
    public var fillColor: NSColor? = nil
    public var pointColor: NSColor? = NSColor.red
    public var pointType = PointType.none

    public var xInterval: ClosedRange<Double> = (0 ... 0)
    public var yInterval: ClosedRange<Double> = (0 ... 0)

    public init() {
        self.points = []
    }
    public init<T: Sequence>(points: T) where T.Iterator.Element == Point {
        self.points = [Point](points)
        updateIntervals()
    }
    public init<T: Sequence>(values: T) where T.Iterator.Element == Double {
        self.points = values.enumerated().map{ Point(x: Double($0.0), y: $0.1) }
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
