// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of PlotKit. The full PlotKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Cocoa
import PlotKit

class ViewController: NSViewController {
    let π = M_PI
    let sampleCount = 1024
    let font = NSFont(name: "Optima", size: 16)!

    var plotView: PlotView!

    override func viewDidLoad() {
        super.viewDidLoad()
        createPlotView()
        createAxes()
        createSinePlot()
        createCosinePlot()
    }

    func createPlotView() {
        plotView = PlotView()
        view.addSubview(plotView)

        plotView.translatesAutoresizingMaskIntoConstraints = false
        plotView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        plotView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        plotView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        plotView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }

    func createAxes() {
        let ticks = [
            TickMark(π/2, label: "π/2"),
            TickMark(π, label: "π"),
            TickMark(3*π/2, label: "3π/2"),
            TickMark(2*π, label: "2π"),
        ]
        var xaxis = Axis(orientation: .Horizontal, ticks: .List(ticks))
        xaxis.position = .Value(0)
        xaxis.labelAttributes = [NSFontAttributeName: font]
        plotView.addAxis(xaxis)

        var yaxis = Axis(orientation: .Vertical, ticks: .Fit(4))
        yaxis.labelAttributes = [NSFontAttributeName: font]
        plotView.addAxis(yaxis)
    }

    func createSinePlot() {
        let t = (0..<sampleCount).map({ 2*π * Double($0) / Double(sampleCount - 1) })
        let y = t.map({ sin($0) })

        let pointSet = PointSet(points: (0..<sampleCount).map{ Point(x: t[$0], y: y[$0]) })
        plotView.addPointSet(pointSet)
    }

    func createCosinePlot() {
        let t = (0..<sampleCount).map({ 2*π * Double($0) / Double(sampleCount - 1) })
        let y = t.map({ cos($0) })

        let pointSet = PointSet(points: (0..<sampleCount).map{ Point(x: t[$0], y: y[$0]) })
        pointSet.lineColor = NSColor.blueColor()
        plotView.addPointSet(pointSet)
    }
}
