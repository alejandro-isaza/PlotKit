// Copyright © 2016 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Cocoa

public class DataView: NSView {
    /// The inverval of x values to render
    public var xInterval: ClosedInterval<Double> = 0...1 {
        didSet {
            needsDisplay = true
        }
    }

    /// The inverval of y values to render
    public var yInterval: ClosedInterval<Double> = 0...1 {
        didSet {
            needsDisplay = true
        }
    }
}
