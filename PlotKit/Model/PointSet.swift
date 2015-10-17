// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation
import Upsurge

public enum PointType {
    case None
    case Ring(radius: Double)
    case Disk(radius: Double)
    case Square(side: Double)
    case FilledSquare(side: Double)
}

public typealias Point = Upsurge.Point<Double>

public class PointSet {
    public var points: [Point]
    public var lines = true
    public var lineWidth = CGFloat(1.0)
    public var color = NSColor.redColor()
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
    public init(points: [Point]) {
        self.points = points
    }
    public init(values: [Double]) {
        var i = 0
        self.points = values.map{ Point(x: Double(i++), y: $0) }
    }
}
