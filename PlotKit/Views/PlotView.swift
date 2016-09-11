// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Cocoa

/// PlotView manages independent data views and draws axes and other plot decorations.
open class PlotView: NSView {
    open var backgroundColor: NSColor?
    open var insets = EdgeInsets(top: 40, left: 60, bottom: 40, right: 60)

    var axisViews = [AxisView]()
    var dataViews = [DataView]()
    var dataXIntervals = [ClosedRange<Double>]()
    var dataYIntervals = [ClosedRange<Double>]()
    var dataTitles = [String]()

    var valueView: NSTextField

    /// If not `nil` the x values are limited to this interval, otherwise the x interval will fit all values
    open var fixedXInterval: ClosedRange<Double>? {
        didSet {
            updateIntervals()
        }
    }

    /// If not `nil` the y values are limited to this interval, otherwise the y interval will fit all values
    open var fixedYInterval: ClosedRange<Double>? {
        didSet {
            updateIntervals()
        }
    }

    /// The x-range that fits all the point sets in the plot
    open internal(set) var fittingXInterval: ClosedRange<Double> = 0.0...1.0

    /// The y-range that fits all the point sets in the plot
    open internal(set) var fittingYInterval: ClosedRange<Double>  = 0.0...1.0

    open func addAxis(_ axis: Axis) {
        let view = AxisView(axis: axis)
        view.insets = insets
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view, positioned: .below, relativeTo: valueView)

        let views = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
            options: .alignAllCenterY, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
            options: .alignAllCenterX, metrics: nil, views: views))

        axisViews.append(view)
        updateIntervals()
    }

    open func removeAllAxes() {
        for view in axisViews {
            view.removeFromSuperview()
        }
        axisViews.removeAll()
    }

    open func addPointSet(_ pointSet: PointSet, title: String = "") {
        let view = PointSetView(pointSet: pointSet)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view, positioned: .below, relativeTo: axisViews.first)

        let views = ["view": view]
        let metrics = [
            "topInset": insets.top as NSNumber,
            "leftInset": insets.left as NSNumber,
            "bottomInset": insets.bottom as NSNumber,
            "rightInset": insets.right as NSNumber,
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(leftInset)-[view]-(rightInset)-|",
            options: .alignAllCenterY, metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(topInset)-[view]-(bottomInset)-|",
            options: .alignAllCenterX, metrics: metrics, views: views))

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

    open func addHeatMap(xInterval: ClosedRange<Double>, yInterval: ClosedRange<Double>, zInterval: ClosedRange<Double>, title: String = "", valueFunction: @escaping HeatMapView.ValueFunction) {
        let view = HeatMapView(valueFunction: valueFunction)
        view.xInterval = xInterval
        view.yInterval = yInterval
        view.zInterval = zInterval
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view, positioned: .below, relativeTo: axisViews.first)

        let views = ["view": view]
        let metrics = [
            "topInset": insets.top,
            "leftInset": insets.left,
            "bottomInset": insets.bottom,
            "rightInset": insets.right,
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(leftInset)-[view]-(rightInset)-|",
            options: .alignAllCenterY, metrics: metrics as [String : NSNumber]?, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(topInset)-[view]-(bottomInset)-|",
            options: .alignAllCenterX, metrics: metrics as [String : NSNumber]?, views: views))

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

    open func removeAllPlots() {
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

    var xInterval: ClosedRange<Double> {
        if let interval = fixedXInterval {
            return interval
        }
        return fittingXInterval 
    }

    var yInterval: ClosedRange<Double> {
        if let interval = fixedYInterval {
            return interval
        }
        return fittingYInterval 
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
        let dataXPadding = abs(xInterval.upperBound - xInterval.lowerBound) * viewPadding / Double(dataViewBounds.width)
        let dataYPadding = abs(yInterval.upperBound - yInterval.lowerBound) * viewPadding / Double(dataViewBounds.height)
        xInterval = xInterval.lowerBound - dataXPadding...xInterval.upperBound + dataXPadding
        yInterval = yInterval.lowerBound - dataYPadding...yInterval.upperBound + dataYPadding

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
        valueView.textColor = NSColor.white
        valueView.backgroundColor = NSColor.black
        valueView.isEditable = false
        valueView.isBordered = false
        valueView.isSelectable = false
        valueView.isHidden = true
        addSubview(valueView)
    }

    open override var isOpaque: Bool {
        return backgroundColor != nil
    }

    override open func draw(_ rect: CGRect) {
        if let color = backgroundColor {
            color.setFill()
            NSRectFill(rect)
        }
    }

    // MARK: - Mouse handling

    open override func updateTrackingAreas() {
        var options = NSTrackingAreaOptions()
        options.formUnion(.activeInActiveApp)
        options.formUnion(.mouseMoved)
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    open override func mouseMoved(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)

        for (view, title) in zip(dataViews, dataTitles) {
            let loc = view.convert(location, from: self)
            if let point = view.pointAt(loc) {
                valueView.stringValue = String(format: "\(title) (%f, %f)", point.x, point.y)
                valueView.isHidden = false
                valueView.sizeToFit()
                var frame = valueView.frame
                frame.origin.x = location.x - frame.width/2
                frame.origin.y = location.y + 4
                valueView.frame = frame
                return
            }
        }

        valueView.isHidden = true
    }
}
