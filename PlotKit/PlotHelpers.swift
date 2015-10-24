// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// Create a PlotView with default axes and the given y-values
public func plotValues<T: SequenceType where T.Generator.Element == Double>(values: T, hTicks: Axis.Ticks = .Fit(5), vTicks: Axis.Ticks = .Fit(5)) -> PlotView {
    let plotSize = NSSize(width: 1024, height: 400)
    let plot = PlotView(frame: NSRect(origin: CGPointZero, size: plotSize))
    plot.addAxis(Axis(orientation: .Horizontal, ticks: hTicks))
    plot.addAxis(Axis(orientation: .Vertical, ticks: vTicks))
    plot.addPointSet(PointSet(values: values))
    return plot
}

/// Create a PlotView with default axes and the given points
public func plotPoints<T: SequenceType where T.Generator.Element == Point>(points: T, hTicks: Axis.Ticks = .Fit(5), vTicks: Axis.Ticks = .Fit(5)) -> PlotView {
    let plotSize = NSSize(width: 1024, height: 400)
    let plot = PlotView(frame: NSRect(origin: CGPointZero, size: plotSize))
    plot.addAxis(Axis(orientation: .Horizontal, ticks: hTicks))
    plot.addAxis(Axis(orientation: .Vertical, ticks: vTicks))
    plot.addPointSet(PointSet(points: points))
    return plot
}
