// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public class PlotView : NSView {
    public var backgroundColor: NSColor = NSColor.whiteColor()
    public var insets = NSEdgeInsets(top: 40, left: 60, bottom: 40, right: 60)

    var axisViews = [AxisView]()
    var pointSetViews = [PointSetView]()

    /// If not `nil` the x values are limited to this interval, otherwise the x interval will fit all values
    public var fixedXInterval: ClosedInterval<Double>? {
        didSet {
            updateIntervals()
        }
    }

    /// If not `nil` the y values are limited to this interval, otherwise the y interval will fit all values
    public var fixedYInterval: ClosedInterval<Double>? {
        didSet {
            updateIntervals()
        }
    }

    /// The x-range that fits all the point sets in the plot
    public var fittingXInterval: ClosedInterval<Double> {
        var interval: ClosedInterval<Double>?
        for view in pointSetViews {
            if let int = interval {
                interval = join(int, view.pointSet.xInterval)
            } else {
                interval = view.pointSet.xInterval
            }
        }
        return interval ?? 0.0...1.0
    }

    /// The y-range that fits all the point sets in the plot
    public var fittingYInterval: ClosedInterval<Double> {
        var interval: ClosedInterval<Double>?
        for view in pointSetViews {
            if let int = interval {
                interval = join(int, view.pointSet.yInterval)
            } else {
                interval = view.pointSet.yInterval
            }
        }
        return interval ?? 0.0...1.0
    }

    public func addAxis(axis: Axis) {
        let view = AxisView(axis: axis)
        view.insets = insets
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view, positioned: .Above, relativeTo: pointSetViews.last)

        let views = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options: .AlignAllCenterY, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options: .AlignAllCenterX, metrics: nil, views: views))

        axisViews.append(view)
        updateIntervals()
    }

    public func addPointSet(pointSet: PointSet) {
        let view = PointSetView(pointSet: pointSet)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view, positioned: .Below, relativeTo: axisViews.first)

        let views = ["view": view]
        let metrics = [
            "topInset": insets.top,
            "leftInset": insets.left,
            "bottomInset": insets.bottom,
            "rightInset": insets.right,
        ]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(leftInset)-[view]-(rightInset)-|",
            options: .AlignAllCenterY, metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(topInset)-[view]-(bottomInset)-|",
            options: .AlignAllCenterX, metrics: metrics, views: views))

        pointSetViews.append(view)
        updateIntervals()
    }

    public func clear() {
        for view in pointSetViews {
            view.removeFromSuperview()
        }
        pointSetViews.removeAll()
    }


    // MARK: - Helper functions

    var xInterval: ClosedInterval<Double> {
        if let interval = fixedXInterval {
            return interval
        }
        return fittingXInterval ?? 0...1
    }

    var yInterval: ClosedInterval<Double> {
        if let interval = fixedYInterval {
            return interval
        }
        return fittingYInterval ?? 0...1
    }

    func updateIntervals() {
        for view in axisViews {
            view.xInterval = xInterval
            view.yInterval = yInterval
        }
        for view in pointSetViews {
            view.xInterval = xInterval
            view.yInterval = yInterval
        }
    }


    // MARK: - NSView overrides

    public override var opaque: Bool {
        return true
    }

    override public func drawRect(rect: CGRect) {
        backgroundColor.setFill()
        NSRectFill(rect)
    }
}
