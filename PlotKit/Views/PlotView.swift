// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Cocoa

/// PlotView manages independent data views and draws axes and other plot decorations.
public class PlotView: NSView {
    public var backgroundColor: NSColor?
    public var insets = NSEdgeInsets(top: 40, left: 60, bottom: 40, right: 60)

    var axisViews = [AxisView]()
    var dataViews = [DataView]()
    var dataXIntervals = [ClosedInterval<Double>]()
    var dataYIntervals = [ClosedInterval<Double>]()
    var dataTitles = [String]()

    var valueView: NSTextField

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
    public internal(set) var fittingXInterval: ClosedInterval<Double> = 0.0...1.0

    /// The y-range that fits all the point sets in the plot
    public internal(set) var fittingYInterval: ClosedInterval<Double>  = 0.0...1.0

    public func addAxis(axis: Axis) {
        let view = AxisView(axis: axis)
        view.insets = insets
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view, positioned: .Below, relativeTo: valueView)

        let views = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options: .AlignAllCenterY, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options: .AlignAllCenterX, metrics: nil, views: views))

        axisViews.append(view)
        updateIntervals()
    }

    public func removeAllAxes() {
        for view in axisViews {
            view.removeFromSuperview()
        }
        axisViews.removeAll()
    }

    public func addPointSet(pointSet: PointSet, title: String = "") {
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

        dataViews.append(view)
        dataTitles.append(title)

        dataXIntervals.append(pointSet.xInterval)
        if dataXIntervals.count == 1 {
            fittingXInterval = pointSet.xInterval
        } else {
            fittingXInterval = join(fittingXInterval, pointSet.xInterval)
        }

        dataYIntervals.append(pointSet.yInterval)
        if dataYIntervals.count == 1 {
            fittingYInterval = pointSet.yInterval
        } else {
            fittingYInterval = join(fittingYInterval, pointSet.yInterval)
        }

        updateIntervals()
    }

    public func addHeatMap(xInterval xInterval: ClosedInterval<Double>, yInterval: ClosedInterval<Double>, zInterval: ClosedInterval<Double>, title: String = "", valueFunction: HeatMapView.ValueFunction) {
        let view = HeatMapView(valueFunction: valueFunction)
        view.xInterval = xInterval
        view.yInterval = yInterval
        view.zInterval = zInterval
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

        dataViews.append(view)
        dataTitles.append(title)

        dataXIntervals.append(xInterval)
        if dataXIntervals.count == 1 {
            fittingXInterval = xInterval
        } else {
            fittingXInterval = join(fittingXInterval, xInterval)
        }

        dataYIntervals.append(yInterval)
        if dataYIntervals.count == 1 {
            fittingYInterval = yInterval
        } else {
            fittingYInterval = join(fittingYInterval, yInterval)
        }

        updateIntervals()
    }

    public func removeAllPlots() {
        for view in dataViews {
            view.removeFromSuperview()
        }
        dataViews.removeAll()
        dataTitles.removeAll()
        dataXIntervals.removeAll()
        dataYIntervals.removeAll()
        fittingXInterval = 0...1
        fittingYInterval = 0...1
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

    /// The bounds of inner data views
    var dataViewBounds: CGRect {
        var bounds = self.bounds
        bounds.origin.x += insets.left
        bounds.origin.y += insets.top
        bounds.size.width -= insets.left + insets.right
        bounds.size.height -= insets.top + insets.bottom

        if bounds.width <= 0 {
            bounds.size.width = 1
        }
        if bounds.height <= 0 {
            bounds.size.height = 1
        }

        return bounds
    }

    func updateIntervals() {
        let viewPadding = 0.5
        let dataViewBounds = self.dataViewBounds
        var xInterval = self.xInterval
        var yInterval = self.yInterval

        // Add padding to data views to avoid clipping things close to the edge
        let dataXPadding = abs(xInterval.end - xInterval.start) * viewPadding / Double(dataViewBounds.width)
        let dataYPadding = abs(yInterval.end - yInterval.start) * viewPadding / Double(dataViewBounds.height)
        xInterval = xInterval.start - dataXPadding...xInterval.end + dataXPadding
        yInterval = yInterval.start - dataYPadding...yInterval.end + dataYPadding

        for view in axisViews {
            view.xInterval = xInterval
            view.yInterval = yInterval
        }
        for view in dataViews {
            view.xInterval = xInterval
            view.yInterval = yInterval
        }
    }


    // MARK: - NSView overrides

    public override init(frame: NSRect) {
        valueView = NSTextField()
        super.init(frame: frame)
        setupValueView()
    }

    public required init?(coder: NSCoder) {
        valueView = NSTextField()
        super.init(coder: coder)
        setupValueView()
    }

    func setupValueView() {
        valueView.textColor = NSColor.whiteColor()
        valueView.backgroundColor = NSColor.blackColor()
        valueView.editable = false
        valueView.bordered = false
        valueView.selectable = false
        valueView.hidden = true
        addSubview(valueView)
    }

    public override var opaque: Bool {
        return backgroundColor != nil
    }

    override public func drawRect(rect: CGRect) {
        if let color = backgroundColor {
            color.setFill()
            NSRectFill(rect)
        }
    }

    // MARK: - Mouse handling

    public override func updateTrackingAreas() {
        var options = NSTrackingAreaOptions()
        options.unionInPlace(.ActiveInActiveApp)
        options.unionInPlace(.MouseMoved)
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    public override func mouseMoved(event: NSEvent) {
        let location = convertPoint(event.locationInWindow, fromView: nil)

        for (view, title) in zip(dataViews, dataTitles) {
            let loc = view.convertPoint(location, fromView: self)
            if let value = view.valueAt(loc) {
                valueView.stringValue = "\(title) - \(value)"
                valueView.hidden = false
                valueView.sizeToFit()
                var frame = valueView.frame
                frame.origin.x = location.x - frame.width/2
                frame.origin.y = location.y + 4
                valueView.frame = frame
                return
            }
        }

        valueView.hidden = true
    }
}
