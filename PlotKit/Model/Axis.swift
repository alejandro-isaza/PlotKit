// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public struct Axis {
    public enum Orientation {
        case Vertical
        case Horizontal
    }

    public enum Position {
        case Start
        case End
        case Value(Double)
    }

    public enum Ticks {
        /// A specific number of ticks evenly spaced
        case Fit(Int)

        /// Ticks with a specific distance between them
        case Distance(Double)

        /// A specific list of ticks
        case List([TickMark])

        public func ticksInInterval(interval: ClosedInterval<Double>) -> [TickMark] {
            switch self {
            case .Fit(let count):
                let distance = (interval.end - interval.start) / Double(count)
                var v = round(interval.start / distance) * distance
                var ticks = [TickMark]()
                while v <= interval.end {
                    ticks.append(TickMark(v))
                    v += distance
                }
                return ticks

            case .Distance(let distance):
                var v = round(interval.start / distance) * distance
                var ticks = [TickMark]()
                while v <= interval.end {
                    ticks.append(TickMark(v))
                    v += distance
                }
                return ticks

            case .List(let ticks):
                return ticks.filter{ interval.contains($0.value) }
            }
        }
    }

    public var orientation: Orientation
    public var position = Position.Start
    public var lineWidth = CGFloat(1.0)
    public var ticks = Ticks.Fit(5)
    public var color = NSColor.blackColor()
    public var labelAttributes: [String: AnyObject] = [NSFontAttributeName: NSFont(name: "Avenir Next", size: 10)!]

    public init(orientation: Orientation) {
        self.orientation = orientation
    }
    public init(orientation: Orientation, ticks: Ticks) {
        self.orientation = orientation
        self.ticks = ticks
    }
}
