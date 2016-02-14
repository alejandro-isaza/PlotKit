# PlotKit

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/PlotKit.svg)](https://img.shields.io/cocoapods/v/PlotKit.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Plots made easy.

![PlotKit Plot](example.png?raw=true "PlotKit Plot")

## Features

- [x] 2D line and scatter plots
- [x] Multiple axes
- [x] Custom tick marks


## Usage

To start using **PlotKit** quickly use the `plotPoints` helper function. It takes a list of points and returns a view that you can use in your app:

```swift
import PlotKit

// Generate some data to plot
let count = 1024
let t = (0..<count).map({ 2*M_PI * Double($0) / Double(count-1) })
let y = t.map({ sin($0) })

// Create a PlotView
let plotView1 = plotPoints((0..<count).map{ Point(x: t[$0], y: y[$0]) }, hTicks: .Fit(6), vTicks: .Fit(4))
```

### Multiple point sets

You can have multiple curves or scatter plots in the same `PlotView`.

```swift
let plotView = PlotView()

let pointSet1 = PointSet(values: values1)
pointSet1.pointType = .Disk(radius: 2)
pointSet2.pointColor = NSColor.redColor()
pointSet1.lineColor = nil
plotView.addPointSet(pointSet1)

let pointSet2 = PointSet(values: values2)
pointSet2.pointType = .None
pointSet2.lineColor = NSColor.blueColor()
plotView.addPointSet(pointSet2)
```


### Axes

You can customize your plot axes. You can have as many axis lines as you want on the same plot.

```swift
let plotView = PlotView()

var xaxis = Axis(orientation: .Horizontal, ticks: .Fit(5))
xaxis.position = .Value(0) 
xaxis.color = NSColor.blueColor()
xaxis.labelAttributes = [NSForegroundColorAttributeName: NSColor.blueColor()]
plotView.addAxis(xaxis)

var yaxis = Axis(orientation: .Vertical, ticks: .Distance(1))
yaxis.lineWidth = 2
plotView.addAxis(yaxis)
```

You can specify ticks in one of three ways:
 * `Fit(n)`: Say how many tick marks you want. **PlotKit** will space them evenly.
 * `Distance(d)`: Say how far appart to place tick marks.
 * `List(l)`: Specify exactly the tick marks you want. This is the most flexible. You get to decide where to put the tick marks and also what their labels, line length and line thickness are.


---

## License

PlotKit is available under the MIT license. See the LICENSE file for more info.
