// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// PointSetView draws a discrete set of 2D points, optionally connecting them with lines. PointSetView does not draw axes or any other plot decorations, use a `PlotView` for that.
open class PointSetView: DataView {
    open var pointSet: PointSet {
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

    public init(pointSet: PointSet, xInterval: ClosedRange<Double>, yInterval: ClosedRange<Double>) {
        self.pointSet = pointSet
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))

        self.xInterval = xInterval
        self.yInterval = yInterval
    }

    open override func pointAt(_ location: NSPoint) -> Point? {
        var minDistance = CGFloat.greatestFiniteMagnitude
        var minPoint: Point? = nil
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

    open override func draw(_ rect: CGRect) {
        let context = NSGraphicsContext.current()?.cgContext
        context?.setLineWidth(pointSet.lineWidth)

        if let color = pointSet.lineColor {
            color.setStroke()
            context?.addPath(path)
            context?.strokePath()
        }

        if let color = pointSet.fillColor {
            color.setFill()
            context?.addPath(closedPath)
            context?.fillPath()
        }

        drawPoints(context)
    }

    var path: CGPath {
        let path = CGMutablePath()
        if pointSet.points.isEmpty {
            return path
        }

        let first = pointSet.points.first!
        let startPoint = convertDataPointToView(first)
        path.move(to: startPoint)

        for point in pointSet.points {
            let point = convertDataPointToView(point)
            path.addLine(to: point)
        }

        return path
    }

    var closedPath: CGPath {
        let path = CGMutablePath()
        if pointSet.points.isEmpty {
            return path
        }

        let first = pointSet.points.first!
        let startPoint = convertDataPointToView(Point(x: first.x, y: 0))
        path.move(to: startPoint)

        for point in pointSet.points {
            let point = convertDataPointToView(point)
            path.addLine(to: point)
        }

        let last = pointSet.points.last!
        let endPoint = convertDataPointToView(Point(x: last.x, y: 0))
        path.addLine(to: endPoint)
        path.closeSubpath()

        return path
    }


    // MARK: - Point drawing

    func drawPoints(_ context: CGContext?) {
        if let color = pointSet.pointColor {
            color.setFill()
        } else if let color = pointSet.lineColor {
            color.setFill()
        } else {
            NSColor.black.setFill()
        }

        for point in pointSet.points {
            let point = convertDataPointToView(point)
            drawPoint(context, center: point)
        }
    }

    func drawPoint(_ context: CGContext?, center: CGPoint) {
        switch pointSet.pointType {
        case .none:
            break

        case .ring(let radius):
            self.drawCircle(context, center: center, radius: radius)

        case .disk(let radius):
            self.drawDisk(context, center: center, radius: radius)

        case .square(let side):
            self.drawSquare(context, center: center, side: side)

        case .filledSquare(let side):
            self.drawFilledSquare(context, center: center, side: side)
        }
    }

    func drawCircle(_ context: CGContext?, center: CGPoint, radius: Double) {
        let rect = NSRect(
            x: center.x - CGFloat(radius),
            y: center.y - CGFloat(radius),
            width: 2 * CGFloat(radius),
            height: 2 * CGFloat(radius))
        context?.strokeEllipse(in: rect)
    }

    func drawDisk(_ context: CGContext?, center: CGPoint, radius: Double) {
        let rect = NSRect(
            x: center.x - CGFloat(radius),
            y: center.y - CGFloat(radius),
            width: 2 * CGFloat(radius),
            height: 2 * CGFloat(radius))
        context?.fillEllipse(in: rect)
    }

    func drawSquare(_ context: CGContext?, center: CGPoint, side: Double) {
        let rect = NSRect(
            x: center.x - CGFloat(side/1),
            y: center.y - CGFloat(side/1),
            width: CGFloat(side),
            height: CGFloat(side))
        context?.stroke(rect)
    }

    func drawFilledSquare(_ context: CGContext?, center: CGPoint, side: Double) {
        let rect = NSRect(
            x: center.x - CGFloat(side/1),
            y: center.y - CGFloat(side/1),
            width: CGFloat(side),
            height: CGFloat(side))
        context?.fill(rect)
    }

    
    // MARK: - NSCoding
    
    public required init?(coder: NSCoder) {
        pointSet = PointSet()
        super.init(coder: coder)
    }
}
