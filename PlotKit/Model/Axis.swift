// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public struct Axis {
    public enum Orientation {
        case vertical
        case horizontal
    }

    public enum Position {
        case start
        case end
        case value(Double)
    }

    public enum Ticks {
        /// A specific number of ticks evenly spaced
        case fit(Int)

        /// Ticks with a specific distance between them
        case distance(Double)

        /// A specific list of ticks
        case list([TickMark])

        public func ticksInInterval(_ interval: ClosedRange<Double>) -> [TickMark] {
            switch self {
            case .fit(let count):
                let distance = (interval.upperBound - interval.lowerBound) / Double(count)
                var v = round(interval.lowerBound / distance) * distance
                var ticks = [TickMark]()
                while v <= interval.upperBound {
                    ticks.append(TickMark(v))
                    v += distance
                }
                return ticks

            case .distance(let distance):
                var v = round(interval.lowerBound / distance) * distance
                var ticks = [TickMark]()
                while v <= interval.upperBound {
                    ticks.append(TickMark(v))
                    v += distance
                }
                return ticks

            case .list(let ticks):
                return ticks.filter{ interval.contains($0.value) }
            }
        }
    }

    public var orientation: Orientation
    public var position = Position.start
    public var lineWidth = CGFloat(1.0)
    public var ticks = Ticks.fit(5)
    public var color = NSColor.black
    public var labelAttributes: [String: AnyObject] = [NSFontAttributeName: NSFont(name: "Avenir Next", size: 10)!]

    public init(orientation: Orientation) {
        self.orientation = orientation
    }
    public init(orientation: Orientation, ticks: Ticks) {
        self.orientation = orientation
        self.ticks = ticks
    }
}
