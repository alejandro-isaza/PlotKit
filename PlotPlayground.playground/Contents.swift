import PlotKit
import Upsurge
import XCPlayground


//: ## Manually generating a wave
//: We generate a sine between 0 and 2π sampled 1024 times
let π = M_PI
let count = 1024
let t = (0..<count).map{ 2*π * Double($0) / Double(count-1) }
let y = sin(RealArray(t))


//: ## Plotting
//: We create a PlotView, configure the x and y axes, and then add a point set with the data
let plotView1 = PlotView(frame: NSRect(x: 0, y: 0, width: 1024, height: 400))

let xaxis1 = Axis(orientation: .Horizontal, ticks: .Fit(count: 6))
plotView1.addAxis(xaxis1)

let yaxis1 = Axis(orientation: .Vertical, ticks: .Fit(count: 4))
plotView1.addAxis(yaxis1)

let pointSet1 = PointSet(points: (0..<count).map{ Point(x: t[$0], y: y[$0]) })
plotView1.addPointSet(pointSet1)

XCPShowView("Wave", view: plotView1)

//: ## Custom tick marks
//: We can also customize the tick marks and the placement of the axes. In the next plot we'll use tick marks for multiples of π and place the x-axis in the middle.
let plotView2 = PlotView(frame: NSRect(x: 0, y: 0, width: 1024, height: 400))

let ticks = [
    TickMark(π/2, label: "π/2"),
    TickMark(π, label: "π"),
    TickMark(3*π/2, label: "3π/2"),
    TickMark(2*π, label: "2π"),
]
var xaxis2 = Axis(orientation: .Horizontal, ticks: .List(ticks: ticks))
xaxis2.position = .Value(0)
plotView2.addAxis(xaxis2)

let yaxis2 = Axis(orientation: .Vertical, ticks: .Fit(count: 4))
plotView2.addAxis(yaxis2)

let pointSet2 = PointSet(points: (0..<count).map{ Point(x: t[$0], y: y[$0]) })
plotView2.addPointSet(pointSet2)

XCPShowView("Tick Marks", view: plotView2)
