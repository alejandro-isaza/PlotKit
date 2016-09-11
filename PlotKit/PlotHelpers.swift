// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// Create a PlotView with default axes and the given y-values
public func plotValues<T: Sequence>(_ values: T, hTicks: Axis.Ticks = .fit(5), vTicks: Axis.Ticks = .fit(5)) -> PlotView where T.Iterator.Element == Double {
    let plotSize = NSSize(width: 1024, height: 400)
    let plot = PlotView(frame: NSRect(origin: CGPoint.zero, size: plotSize))
    plot.addAxis(Axis(orientation: .horizontal, ticks: hTicks))
    plot.addAxis(Axis(orientation: .vertical, ticks: vTicks))
    plot.addPointSet(PointSet(values: values))
    return plot
}

/// Create a PlotView with default axes and the given points
public func plotPoints<T: Sequence>(_ points: T, hTicks: Axis.Ticks = .fit(5), vTicks: Axis.Ticks = .fit(5)) -> PlotView where T.Iterator.Element == Point {
    let plotSize = NSSize(width: 1024, height: 400)
    let plot = PlotView(frame: NSRect(origin: CGPoint.zero, size: plotSize))
    plot.addAxis(Axis(orientation: .horizontal, ticks: hTicks))
    plot.addAxis(Axis(orientation: .vertical, ticks: vTicks))
    plot.addPointSet(PointSet(points: points))
    return plot
}
