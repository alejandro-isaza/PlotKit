// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

internal class PointSetView: NSView {
    var pointSet: PointSet {
        didSet {
            needsDisplay = true
        }
    }

    var xInterval: ClosedInterval<Double>
    var yInterval: ClosedInterval<Double>

    init() {
        pointSet = PointSet()
        xInterval = 0...1
        yInterval = 0...1
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))
    }

    init(pointSet: PointSet) {
        self.pointSet = pointSet
        self.xInterval = pointSet.xInterval ?? 0...1
        self.yInterval = pointSet.yInterval ?? 0...1
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))
    }

    init(pointSet: PointSet, xInterval: ClosedInterval<Double>, yInterval: ClosedInterval<Double>) {
        self.pointSet = pointSet
        self.xInterval = xInterval
        self.yInterval = yInterval
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))
    }

    override func drawRect(rect: CGRect) {
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
        let startPoint = convertToView(x: first.x, y: first.y)
        CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y)

        for point in pointSet.points {
            let point = convertToView(x: point.x, y: point.y)
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
        let startPoint = convertToView(x: first.x, y: 0)
        CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y)

        for point in pointSet.points {
            let point = convertToView(x: point.x, y: point.y)
            CGPathAddLineToPoint(path, nil, point.x, point.y)
        }

        let last = pointSet.points.last!
        let endPoint = convertToView(x: last.x, y: 0)
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
            let point = convertToView(x: point.x, y: point.y)
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

    // MARK: - Helper functions

    func convertToView(x x: Double, y: Double) -> CGPoint {
        let boundsXInterval = Double(bounds.minX)...Double(bounds.maxX)
        let boundsYInterval = Double(bounds.minY)...Double(bounds.maxY)
        return CGPoint(
            x: mapValue(x, fromInterval: xInterval, toInterval: boundsXInterval),
            y: mapValue(y, fromInterval: yInterval, toInterval: boundsYInterval))
    }

    
    // MARK: - NSCoding
    
    required init?(coder: NSCoder) {
        pointSet = PointSet()
        xInterval = 0.0...0.0
        yInterval = 0.0...0.0
        super.init(coder: coder)
    }
}
