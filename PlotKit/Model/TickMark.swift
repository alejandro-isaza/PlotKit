//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation

public struct TickMark {
    public var value: Double
    public var label: String
    public var lineWidth = CGFloat(1.0)
    public var lineLength = CGFloat(5.0)

    public init(_ value: Double) {
        self.value = value
        label = String(format: "%.5g", arguments: [value])
    }

    public init(_ value: Int) {
        self.value = Double(value)
        label = "\(value)"
    }

    public init(_ value: Double, label: String) {
        self.value = value
        self.label = label
    }
}
