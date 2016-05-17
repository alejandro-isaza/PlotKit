// Copyright © 2016 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// HeatMapView draws continuous 3D data using a heat map. The data is provided by a value function that should return a `z` value for any `x, y` value pair inside the plot region. HeatMapView does not draw axes or any other plot decorations, use a `PlotView` for that.
public class HeatMapView: DataView {
    public typealias ValueFunction = (x: Double, y: Double) -> Double

    /// The colo map determines the color to use for each value
    public var colorMap: ColorMap {
        didSet {
            needsDisplay = true
        }
    }

    /// The inverval of z values that the value function generates
    public var zInterval: ClosedInterval<Double> {
        didSet {
            needsDisplay = true
        }
    }

    /// A function that maps from an `x, y` value pair to a `z` value
    public var valueFunction: ValueFunction? {
        didSet {
            needsDisplay = true
        }
    }

    public init() {
        colorMap = ViridisColorMap()
        zInterval = 0...1
        super.init(frame: NSRect(x: 0, y: 0, width: 512, height: 512))
        canDrawConcurrently = true
    }

    public required init?(coder: NSCoder) {
        colorMap = ViridisColorMap()
        zInterval = 0...1
        super.init(coder: coder)
        canDrawConcurrently = true
    }

    public convenience init(valueFunction: ValueFunction) {
        self.init()
        self.valueFunction = valueFunction
    }

    public override func drawRect(rect: CGRect) {
        guard let valueFunction = valueFunction else {
            return
        }

        let scaleFactor = window?.screen?.backingScaleFactor ?? 1.0
        let pixelsWide = Int(rect.width * scaleFactor)
        let pixelsHigh = Int(rect.height * scaleFactor)
        let bytesPerRow = pixelsWide * 4

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGBitmapContextCreate(nil,
            pixelsWide, pixelsHigh,
            8, bytesPerRow, colorSpace,
            CGImageAlphaInfo.PremultipliedLast.rawValue)
        let data = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(context))

        let repXInterval = 0.0...Double(pixelsWide)
        let repYInterval = 0.0...Double(pixelsHigh)
        let rectXInterval = Double(rect.minX)...Double(rect.maxX)
        let rectYInterval = Double(rect.minY)...Double(rect.maxY)
        let boundsXInterval = Double(bounds.minX)...Double(bounds.maxX)
        let boundsYInterval = Double(bounds.minY)...Double(bounds.maxY)

        for yi in 0..<pixelsHigh {
            let yv = mapValue(Double(yi), fromInterval: repYInterval, toInterval: rectYInterval)
            let yb = mapValue(yv, fromInterval: rectYInterval, toInterval: boundsYInterval)
            let y = mapValue(yb, fromInterval: boundsYInterval, toInterval: yInterval)
            for xi in 0..<pixelsWide {
                let xv = mapValue(Double(xi), fromInterval: repXInterval, toInterval: rectXInterval)
                let xb = mapValue(xv, fromInterval: rectXInterval, toInterval: boundsXInterval)
                let x = mapValue(xb, fromInterval: boundsXInterval, toInterval: xInterval)

                let value = valueFunction(x: x, y: y)
                let normValue = mapValue(value, fromInterval: zInterval, toInterval: 0.0...1.0)
                let color = colorMap.colorForValue(normValue)
                data[xi * 4 + yi * bytesPerRow + 0] = UInt8(round(color.red * 255))
                data[xi * 4 + yi * bytesPerRow + 1] = UInt8(round(color.green * 255))
                data[xi * 4 + yi * bytesPerRow + 2] = UInt8(round(color.blue * 255))
                data[xi * 4 + yi * bytesPerRow + 3] = UInt8(round(color.alpha * 255))
            }
        }

        let image = CGBitmapContextCreateImage(context)
        CGContextDrawImage(NSGraphicsContext.currentContext()?.CGContext, rect, image)
    }

    public override func pointAt(location: NSPoint) -> Point? {
        let point = convertViewPointToData(location)
        return Point(x: point.x, y: valueFunction?(x: point.x, y: point.y) ?? 0)
    }
}
