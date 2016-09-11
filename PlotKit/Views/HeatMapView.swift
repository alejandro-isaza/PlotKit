// Copyright © 2016 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// HeatMapView draws continuous 3D data using a heat map. The data is provided by a value function that should return a `z` value for any `x, y` value pair inside the plot region. HeatMapView does not draw axes or any other plot decorations, use a `PlotView` for that.
open class HeatMapView: DataView {
    public typealias ValueFunction = (_ x: Double, _ y: Double) -> Double

    /// The colo map determines the color to use for each value
    open var colorMap: ColorMap {
        didSet {
            needsDisplay = true
        }
    }

    /// The inverval of z values that the value function generates
    open var zInterval: ClosedRange<Double> {
        didSet {
            needsDisplay = true
        }
    }

    /// A function that maps from an `x, y` value pair to a `z` value
    open var valueFunction: ValueFunction? {
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

    public convenience init(valueFunction: @escaping ValueFunction) {
        self.init()
        self.valueFunction = valueFunction
    }

    open override func draw(_ rect: CGRect) {
        guard let valueFunction = valueFunction else {
            return
        }

        let scaleFactor = window?.screen?.backingScaleFactor ?? 1.0
        let pixelsWide = Int(rect.width * scaleFactor)
        let pixelsHigh = Int(rect.height * scaleFactor)
        let bytesPerRow = pixelsWide * 4

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
            width: pixelsWide, height: pixelsHigh,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let data = context?.data?.bindMemory(to: UInt8.self, capacity: bytesPerRow * pixelsHigh) else {
            return
        }

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

                let value = valueFunction(x, y)
                let normValue = mapValue(value, fromInterval: zInterval, toInterval: 0.0...1.0)
                let color = colorMap.colorForValue(normValue)
                data[xi * 4 + yi * bytesPerRow + 0] = UInt8(round(color.red * 255))
                data[xi * 4 + yi * bytesPerRow + 1] = UInt8(round(color.green * 255))
                data[xi * 4 + yi * bytesPerRow + 2] = UInt8(round(color.blue * 255))
                data[xi * 4 + yi * bytesPerRow + 3] = UInt8(round(color.alpha * 255))
            }
        }

        let image = context?.makeImage()
        NSGraphicsContext.current()?.cgContext.draw(image!, in: rect)
    }

    open override func pointAt(_ location: NSPoint) -> Point? {
        let point = convertViewPointToData(location)
        return Point(x: point.x, y: valueFunction?(point.x, point.y) ?? 0)
    }
}
