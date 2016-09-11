// Copyright © 2016 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Cocoa
import PlotKit

class HeatMapViewController: NSViewController {
    let π = M_PI
    let font = NSFont(name: "Optima", size: 16)!

    @IBOutlet weak var plotView: PlotView!

    override func viewDidLoad() {
        super.viewDidLoad()
        createAxes()
        createPlot()
    }

    func createAxes() {
        let ticks = [
            TickMark(-π/2, label: "-π/2"),
            TickMark(-π, label: "-π"),
            TickMark(π/2, label: "π/2"),
            TickMark(π, label: "π"),
        ]

        var xaxis = Axis(orientation: .horizontal, ticks: .list(ticks))
        xaxis.position = .value(0)
        xaxis.labelAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: NSColor.cyan]
        plotView.addAxis(xaxis)

        var yaxis = Axis(orientation: .vertical, ticks: .list(ticks))
        yaxis.position = .value(0)
        yaxis.labelAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: NSColor.cyan]
        plotView.addAxis(yaxis)
    }

    func createPlot() {
        plotView.addHeatMap(xInterval: -M_PI...M_PI, yInterval: -M_PI...M_PI, zInterval: -1...1) { x, y in
            return cos(abs(x) + abs(y))
        }
    }

}
