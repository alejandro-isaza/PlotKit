// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Cocoa
import PlotKit
import Upsurge

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        createSinePlot()
    }

    func createSinePlot() {
        let π = M_PI
        let count = 1024
        let t = (0..<count).map{ 2*π * Double($0) / Double(count-1) }
        let y = sin(RealArray(t))

        let plot = plotPoints((0..<count).map{ Point(x: t[$0], y: y[$0]) }, hTicks: .Fit(6), vTicks: .Fit(4))
        plot.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plot)

        plot.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        plot.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        plot.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        plot.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }
}
