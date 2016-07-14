// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

internal class AxisView: NSView {
    var insets = EdgeInsets(top: 40, left: 60, bottom: 40, right: 60)

    var axis: Axis {
        didSet {
            needsDisplay = true
        }
    }

    var xInterval = 0.0...1.0 {
        didSet {
            needsDisplay = true
        }
    }
    var yInterval = 0.0...1.0 {
        didSet {
            needsDisplay = true
        }
    }

    init(axis: Axis) {
        self.axis = axis
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))
    }


    // MARK: - NSView overrides

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        axis.color.setFill()
        switch axis.orientation {
        case .vertical:
            drawVertical(rect)
        case .horizontal:
            drawHorizontal(rect)
        }
    }

    override var intrinsicContentSize: NSSize {
        switch axis.orientation {
        case .horizontal:
            var height = CGFloat(0)
            for tick in axis.ticks.ticksInInterval(xInterval) {
                let string = tick.label as NSString
                let size = string.size(withAttributes: axis.labelAttributes)
                if size.height > height {
                    height = size.height
                }
            }
            return NSSize(width: NSViewNoIntrinsicMetric, height: height)

        case .vertical:
            var width = CGFloat(0)
            for tick in axis.ticks.ticksInInterval(yInterval) {
                let string = tick.label as NSString
                let size = string.size(withAttributes: axis.labelAttributes)
                if size.width > width {
                    width = size.width
                }
            }
            return NSSize(width: width, height: NSViewNoIntrinsicMetric)
        }
    }


    // MARK: - Helper functions

    func drawVertical(_ rect: CGRect) {
        var cappedInsets = insets
        if insets.left + insets.right >= bounds.width {
            cappedInsets.left = 0
            cappedInsets.right = 0
        }
        if insets.top + insets.bottom >= bounds.height {
            cappedInsets.top = 0
            cappedInsets.bottom = 0
        }
        let boundsXInterval = Double(bounds.minX + cappedInsets.left)...Double(bounds.maxX - cappedInsets.right)
        let boundsYInterval = Double(bounds.minY + cappedInsets.bottom)...Double(bounds.maxY - cappedInsets.top)

        guard let context = NSGraphicsContext.current()?.cgContext else {
            return
        }
        let width = CGFloat(axis.lineWidth)
        let height = bounds.height - insets.top - insets.bottom

        // Draw axis line
        let x: CGFloat
        switch axis.position {
        case .start:
            x = CGFloat(boundsXInterval.lowerBound) + width/2

        case .end:
            x = CGFloat(boundsXInterval.upperBound) - width/2

        case .value(let position):
            x = CGFloat(mapValue(position, fromInterval: xInterval, toInterval: boundsXInterval))
        }
        let axisRect = CGRect(x: x - width/2, y: CGFloat(boundsYInterval.lowerBound), width: width, height: height)
        context.fill(axisRect)

        // Draw tick marks
        var lastTextFrame = NSRect()
        for tick in axis.ticks.ticksInInterval(yInterval) {
            if !yInterval.contains(tick.value) {
                continue
            }

            let y = CGFloat(mapValue(tick.value, fromInterval: yInterval, toInterval: boundsYInterval))
            let rect = NSRect(
                x: x - tick.lineLength/2,
                y: y - tick.lineWidth/2,
                width: tick.lineLength,
                height: tick.lineWidth)
            context.fill(rect)

            let string = tick.label as NSString
            let size = string.size(withAttributes: axis.labelAttributes)
            let point: NSPoint
            switch axis.position {
            case .start, .value:
                point = NSPoint(
                    x: x - size.width - tick.lineLength,
                    y: y - size.height/2)

            case .end:
                point = NSPoint(
                    x: x + tick.lineLength,
                    y: y - size.height/2)
            }

            let frame = NSRect(origin: point, size: size)
            if !lastTextFrame.intersects(frame) {
                string.draw(at: point, withAttributes: axis.labelAttributes)
                lastTextFrame = frame
            }
        }
    }

    func drawHorizontal(_ rect: CGRect) {
        var cappedInsets = insets
        if insets.left + insets.right >= bounds.width {
            cappedInsets.left = 0
            cappedInsets.right = 0
        }
        if insets.top + insets.bottom >= bounds.height {
            cappedInsets.top = 0
            cappedInsets.bottom = 0
        }
        let boundsXInterval = Double(bounds.minX + cappedInsets.left)...Double(bounds.maxX - cappedInsets.right)
        let boundsYInterval = Double(bounds.minY + cappedInsets.bottom)...Double(bounds.maxY - cappedInsets.top)

        guard let context = NSGraphicsContext.current()?.cgContext else {
            return
        }
        let width = bounds.width - insets.left - insets.right
        let height = CGFloat(axis.lineWidth)

        // Draw axis line
        let y: CGFloat
        switch axis.position {
        case .start:
            y = CGFloat(boundsYInterval.lowerBound) + height/2

        case .end:
            y = CGFloat(boundsYInterval.upperBound) - height/2

        case .value(let position):
            y = CGFloat(mapValue(position, fromInterval: yInterval, toInterval: boundsYInterval))
        }
        let axisRect = CGRect(x: CGFloat(boundsXInterval.lowerBound), y: y - height/2, width: width, height: height)
        context.fill(axisRect)

        // Draw tick marks
        var lastTextFrame = NSRect()
        for tick in axis.ticks.ticksInInterval(xInterval) {
            if !xInterval.contains(tick.value) {
                continue
            }

            let x = CGFloat(mapValue(tick.value, fromInterval: xInterval, toInterval: boundsXInterval))
            let rect = CGRect(
                x: x - tick.lineWidth/2,
                y: y - tick.lineLength/2,
                width: tick.lineWidth,
                height: tick.lineLength)
            context.fill(rect)

            let string = tick.label as NSString
            let size = string.size(withAttributes: axis.labelAttributes)
            var point: NSPoint
            switch axis.position {
            case .start, .value:
                point = NSPoint(
                    x: x - size.width/2,
                    y: y - size.height)

            case .end:
                point = NSPoint(
                    x: x - size.width/2,
                    y: y + tick.lineLength)
            }

            let frame = NSRect(origin: point, size: size)
            if !lastTextFrame.intersects(frame) {
                string.draw(at: point, withAttributes: axis.labelAttributes)
                lastTextFrame = frame
            }
        }
    }
}
