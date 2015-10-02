//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation
import Surge

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
        case Fit(count: Int)

        /// Ticks with a specific distance between them
        case Space(distance: Double)

        /// A specific list of ticks
        case List(ticks: [TickMark])

        public func ticksInInterval(interval: Interval) -> [TickMark] {
            switch self {
            case .Fit(let count):
                return (0...count).map{
                    TickMark(interval.min + Double($0) * (interval.max - interval.min) / Double(count))
                }

            case .Space(let distance):
                var v = round(interval.min / distance) * distance
                var ticks = [TickMark]()
                while v <= interval.max {
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
    public var ticks = Ticks.Fit(count: 10)
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
