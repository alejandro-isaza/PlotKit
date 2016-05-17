// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// PointSetView draws a discrete set of 2D points, optionally connecting them with lines. PointSetView does not draw axes or any other plot decorations, use a `PlotView` for that.
public class PointSetView: DataView {
    public var pointSet: PointSet {
        didSet {
            needsDisplay = true
        }
    }

    public init() {
        pointSet = PointSet()
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))
    }

    public init(pointSet: PointSet) {
        self.pointSet = pointSet
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))

        self.xInterval = pointSet.xInterval
        self.yInterval = pointSet.yInterval
    }

    public init(pointSet: PointSet, xInterval: ClosedInterval<Double>, yInterval: ClosedInterval<Double>) {
        self.pointSet = pointSet
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))

        self.xInterval = xInterval
        self.yInterval = yInterval
    }

    public override func pointAt(location: NSPoint) -> Point? {
        var minDistance = CGFloat.max
        var minPoint = Point?()
        for point in pointSet.points {
            let viewPoint = convertDataPointToView(point)
            let d = hypot(location.x - viewPoint.x, location.y - viewPoint.y)
            if d < 8 && d < minDistance {
                minDistance = d
                minPoint = point
            }
        }
        return minPoint
    }

    public override func drawRect(rect: CGRect) {
        let context = NSGraphicsContext.currentContext()?.CGContext
        CGContextSetLineWidth(context, pointSet.lineWidth)

        if let color = pointSet.lineColor {
            color.setStroke()
            CGContextAddPath(context, path)
            CGContextStrokePath(context)
        }

        if let color = pointSet.fillColor {
            color.setFill()
            CGContextAddPath(context, closedPath)
            CGContextFillPath(context)
        }

        drawPoints(context)
    }

    var path: CGPath {
        let path = CGPathCreateMutable()
        if pointSet.points.isEmpty {
            return path
        }

        let first = pointSet.points.first!
        let startPoint = convertDataPointToView(first)
        CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y)

        for point in pointSet.points {
            let point = convertDataPointToView(point)
            CGPathAddLineToPoint(path, nil, point.x, point.y)
        }

        return path
    }

    var closedPath: CGPath {
        let path = CGPathCreateMutable()
        if pointSet.points.isEmpty {
            return path
        }

        let first = pointSet.points.first!
        let startPoint = convertDataPointToView(Point(x: first.x, y: 0))
        CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y)

        for point in pointSet.points {
            let point = convertDataPointToView(point)
            CGPathAddLineToPoint(path, nil, point.x, point.y)
        }

        let last = pointSet.points.last!
        let endPoint = convertDataPointToView(Point(x: last.x, y: 0))
        CGPathAddLineToPoint(path, nil, endPoint.x, endPoint.y)
        CGPathCloseSubpath(path)

        return path
    }


    // MARK: - Point drawing

    func drawPoints(context: CGContext?) {
        if let color = pointSet.pointColor {
            color.setFill()
        } else if let color = pointSet.lineColor {
            color.setFill()
        } else {
            NSColor.blackColor().setFill()
        }

        for point in pointSet.points {
            let point = convertDataPointToView(point)
            drawPoint(context, center: point)
        }
    }

    func drawPoint(context: CGContext?, center: CGPoint) {
        switch pointSet.pointType {
        case .None:
            break

        case .Ring(let radius):
            self.drawCircle(context, center: center, radius: radius)

        case .Disk(let radius):
            self.drawDisk(context, center: center, radius: radius)

        case .Square(let side):
            self.drawSquare(context, center: center, side: side)

        case .FilledSquare(let side):
            self.drawFilledSquare(context, center: center, side: side)
        }
    }

    func drawCircle(context: CGContextRef?, center: CGPoint, radius: Double) {
        let rect = NSRect(
            x: center.x - CGFloat(radius),
            y: center.y - CGFloat(radius),
            width: 2 * CGFloat(radius),
            height: 2 * CGFloat(radius))
        CGContextStrokeEllipseInRect(context, rect)
    }

    func drawDisk(context: CGContextRef?, center: CGPoint, radius: Double) {
        let rect = NSRect(
            x: center.x - CGFloat(radius),
            y: center.y - CGFloat(radius),
            width: 2 * CGFloat(radius),
            height: 2 * CGFloat(radius))
        CGContextFillEllipseInRect(context, rect)
    }

    func drawSquare(context: CGContextRef?, center: CGPoint, side: Double) {
        let rect = NSRect(
            x: center.x - CGFloat(side/1),
            y: center.y - CGFloat(side/1),
            width: CGFloat(side),
            height: CGFloat(side))
        CGContextStrokeRect(context, rect)
    }

    func drawFilledSquare(context: CGContextRef?, center: CGPoint, side: Double) {
        let rect = NSRect(
            x: center.x - CGFloat(side/1),
            y: center.y - CGFloat(side/1),
            width: CGFloat(side),
            height: CGFloat(side))
        CGContextFillRect(context, rect)
    }

    
    // MARK: - NSCoding
    
    public required init?(coder: NSCoder) {
        pointSet = PointSet()
        super.init(coder: coder)
    }
}
