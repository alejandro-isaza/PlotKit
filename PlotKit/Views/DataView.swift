// Copyright © 2016 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Cocoa

open class DataView: NSView {
    /// The inverval of x values to render
    open var xInterval: ClosedRange<Double> = 0...1 {
        didSet {
            needsDisplay = true
        }
    }

    /// The inverval of y values to render
    open var yInterval: ClosedRange<Double> = 0...1 {
        didSet {
            needsDisplay = true
        }
    }

    /// Return the data value at the specified location in the view or `nil` if there is no data point at that location
    open func pointAt(_ location: NSPoint) -> Point? {
        return nil
    }

    /// Converts a point from the data's coordinate system to the view's coordinate system
    open func convertDataPointToView(_ dataPoint: Point) -> CGPoint {
        let boundsXInterval = Double(bounds.minX)...Double(bounds.maxX)
        let boundsYInterval = Double(bounds.minY)...Double(bounds.maxY)
        return CGPoint(
            x: mapValue(dataPoint.x, fromInterval: xInterval, toInterval: boundsXInterval),
            y: mapValue(dataPoint.y, fromInterval: yInterval, toInterval: boundsYInterval)
        )
    }

    /// Converts a point from the view's coordinate system to the data's coordinate system
    open func convertViewPointToData(_ viewPoint: CGPoint) -> Point {
        let boundsXInterval = Double(bounds.minX)...Double(bounds.maxX)
        let boundsYInterval = Double(bounds.minY)...Double(bounds.maxY)
        return Point(
            x: mapValue(Double(viewPoint.x), fromInterval: boundsXInterval, toInterval: xInterval),
            y: mapValue(Double(viewPoint.y), fromInterval: boundsYInterval, toInterval: yInterval)
        )
    }
}
