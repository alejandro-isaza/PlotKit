//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation
import Surge

internal class AxisView: NSView {
    var insets = NSEdgeInsets(top: 40, left: 60, bottom: 40, right: 60)

    var axis: Axis {
        didSet {
            needsDisplay = true
        }
    }

    var xInterval = Interval(min: 0.0, max: 1.0) {
        didSet {
            needsDisplay = true
        }
    }
    var yInterval = Interval(min: 0.0, max: 1.0) {
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

    override func drawRect(rect: CGRect) {
        axis.color.setFill()
        switch axis.orientation {
        case .Vertical:
            drawVertical(rect)
        case .Horizontal:
            drawHorizontal(rect)
        }
    }

    override var intrinsicContentSize: NSSize {
        switch axis.orientation {
        case .Horizontal:
            var height = CGFloat(0)
            for tick in axis.ticks.ticksInInterval(xInterval) {
                let string = tick.label as NSString
                let size = string.sizeWithAttributes(axis.labelAttributes)
                if size.height > height {
                    height = size.height
                }
            }
            return NSSize(width: NSViewNoInstrinsicMetric, height: height)

        case .Vertical:
            var width = CGFloat(0)
            for tick in axis.ticks.ticksInInterval(yInterval) {
                let string = tick.label as NSString
                let size = string.sizeWithAttributes(axis.labelAttributes)
                if size.width > width {
                    width = size.width
                }
            }
            return NSSize(width: width, height: NSViewNoInstrinsicMetric)
        }
    }


    // MARK: - Helper functions

    func drawVertical(rect: CGRect) {
        let boundsXInterval = Interval(min: Double(bounds.minX + insets.left), max: Double(bounds.maxX - insets.right))
        let boundsYInterval = Interval(min: Double(bounds.minY + insets.bottom), max: Double(bounds.maxY - insets.top))

        let context = NSGraphicsContext.currentContext()?.CGContext
        let width = CGFloat(axis.lineWidth)
        let height = bounds.height - insets.top - insets.bottom

        // Draw axis line
        let x: CGFloat
        switch axis.position {
        case .Start:
            x = CGFloat(boundsXInterval.min) + width/2

        case .End:
            x = CGFloat(boundsXInterval.max) - width/2

        case .Value(let position):
            x = CGFloat(mapValue(position, fromInterval: xInterval, toInterval: boundsXInterval))
        }
        let axisRect = CGRectMake(x - width/2, CGFloat(boundsYInterval.min), width, height)
        CGContextFillRect(context, axisRect)

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
            CGContextFillRect(context, rect)

            let string = tick.label as NSString
            let size = string.sizeWithAttributes(axis.labelAttributes)
            let point: NSPoint
            switch axis.position {
            case .Start, .Value:
                point = NSPoint(
                    x: x - size.width - tick.lineLength,
                    y: y - size.height/2)

            case .End:
                point = NSPoint(
                    x: x + tick.lineLength,
                    y: y - size.height/2)
            }

            let frame = NSRect(origin: point, size: size)
            if !lastTextFrame.intersects(frame) {
                string.drawAtPoint(point, withAttributes: axis.labelAttributes)
                lastTextFrame = frame
            }
        }
    }

    func drawHorizontal(rect: CGRect) {
        let boundsXInterval = Interval(min: Double(bounds.minX + insets.left), max: Double(bounds.maxX - insets.right))
        let boundsYInterval = Interval(min: Double(bounds.minY + insets.bottom), max: Double(bounds.maxY - insets.top))

        let context = NSGraphicsContext.currentContext()?.CGContext
        let width = bounds.width - insets.left - insets.right
        let height = CGFloat(axis.lineWidth)

        // Draw axis line
        let y: CGFloat
        switch axis.position {
        case .Start:
            y = CGFloat(boundsYInterval.min) + height/2

        case .End:
            y = CGFloat(boundsYInterval.max) - height/2

        case .Value(let position):
            y = CGFloat(mapValue(position, fromInterval: yInterval, toInterval: boundsYInterval))
        }
        let axisRect = CGRectMake(CGFloat(boundsXInterval.min), y - height/2, width, height)
        CGContextFillRect(context, axisRect)

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
            CGContextFillRect(context, rect)

            let string = tick.label as NSString
            let size = string.sizeWithAttributes(axis.labelAttributes)
            var point: NSPoint
            switch axis.position {
            case .Start, .Value:
                point = NSPoint(
                    x: x - size.width/2,
                    y: y - size.height)

            case .End:
                point = NSPoint(
                    x: x - size.width/2,
                    y: y + tick.lineLength)
            }

            let frame = NSRect(origin: point, size: size)
            if !lastTextFrame.intersects(frame) {
                string.drawAtPoint(point, withAttributes: axis.labelAttributes)
                lastTextFrame = frame
            }
        }
    }
}
