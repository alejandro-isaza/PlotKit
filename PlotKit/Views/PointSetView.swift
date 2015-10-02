//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation
import Surge

internal class PointSetView: NSView {
    var pointSet: PointSet {
        didSet {
            needsDisplay = true
        }
    }

    var xInterval: Interval
    var yInterval: Interval

    init() {
        pointSet = PointSet()
        xInterval = pointSet.xInterval
        yInterval = pointSet.yInterval
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))
    }
    
    init(pointSet: PointSet) {
        self.pointSet = pointSet
        self.xInterval = pointSet.xInterval
        self.yInterval = pointSet.yInterval
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))
    }

    init(pointSet: PointSet, xInterval: Interval, yInterval: Interval) {
        self.pointSet = pointSet
        self.xInterval = xInterval
        self.yInterval = yInterval
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))
    }

    override func drawRect(rect: CGRect) {
        let context = NSGraphicsContext.currentContext()?.CGContext
        pointSet.color.setStroke()
        pointSet.color.setFill()
        CGContextSetLineWidth(context, pointSet.lineWidth)

        if let first = pointSet.points.first {
            let startPoint = convertToView(x: first.x, y: first.y)
            CGContextMoveToPoint(context, startPoint.x, startPoint.y)
        }

        let drawPoint = drawPointForPointSet()
        for point in pointSet.points {
            let point = convertToView(x: point.x, y: point.y)
            CGContextAddLineToPoint(context, point.x, point.y)
            drawPoint(context, point)
        }

        if pointSet.lines {
            CGContextStrokePath(context)
        }
    }

    // MARK: - Point drawing

    func drawPointForPointSet() -> (CGContextRef?, CGPoint) -> () {
        switch pointSet.pointType {
        case .None:
            return { _, _ in }

        case .Ring(let radius):
            return { context, center in
                self.drawCircle(context, center: center, radius: radius)
            }

        case .Disk(let radius):
            return { context, center in
                self.drawDisk(context, center: center, radius: radius)
            }

        case .Square(let side):
            return { context, center in
                self.drawSquare(context, center: center, side: side)
            }

        case .FilledSquare(let side):
            return { context, center in
                self.drawFilledSquare(context, center: center, side: side)
            }
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
        let boundsXInterval = Interval(min: Double(bounds.minX), max: Double(bounds.maxX))
        let boundsYInterval = Interval(min: Double(bounds.minY), max: Double(bounds.maxY))
        return CGPoint(
            x: mapValue(x, fromInterval: xInterval, toInterval: boundsXInterval),
            y: mapValue(y, fromInterval: yInterval, toInterval: boundsYInterval))
    }
    

    // MARK: - NSCoding

    required init?(coder: NSCoder) {
        pointSet = PointSet()
        xInterval = Interval(min: 0.0, max: 0.0)
        yInterval = Interval(min: 0.0, max: 0.0)
        super.init(coder: coder)
    }
}
