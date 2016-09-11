import PlotKit
import PlaygroundSupport

let π = M_PI

//: ## Manually generating a wave
//: We generate a sine between 0 and 2π sampled 1024 times
let count = 1024
let t = (0..<count).map({ 2*π * Double($0) / Double(count-1) })
let y = t.map({ sin($0) })


//: ## Plotting
//: We create a PlotView, configure the x and y axes, and then add a point set with the data
let plotView1 = plotPoints((0..<count).map{ Point(x: t[$0], y: y[$0]) }, hTicks: .fit(6), vTicks: .fit(4))
PlaygroundPage.current.liveView = plotView1
plotView1

//: ## Custom tick marks
//: We can also customize the tick marks and the placement of the axes. In the next plot we'll use tick marks for multiples of π and place the x-axis in the middle.
let plotView2 = PlotView(frame: NSRect(x: 0, y: 0, width: 1024, height: 400))

let ticks = [
    TickMark(π/2, label: "π/2"),
    TickMark(π, label: "π"),
    TickMark(3*π/2, label: "3π/2"),
    TickMark(2*π, label: "2π"),
]
var xaxis2 = Axis(orientation: .horizontal, ticks: .list(ticks))
xaxis2.position = .value(0)
plotView2.addAxis(xaxis2)

let yaxis2 = Axis(orientation: .vertical, ticks: .fit(4))
plotView2.addAxis(yaxis2)

let pointSet2 = PointSet(points: (0..<count).map{ Point(x: t[$0], y: y[$0]) })
plotView2.addPointSet(pointSet2)

PlaygroundPage.current.liveView = plotView2
plotView2
