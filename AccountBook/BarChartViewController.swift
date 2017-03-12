//
//  BarChartViewController.swift
//  AccountBook
//
//  Created by yang on 3/11/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CorePlot

// Cite: https://www.raywenderlich.com/131985/core-plot-tutorial-getting-started
class BarChartViewController: UIViewController {
    @IBOutlet var hostView: CPTGraphHostingView!
    var expensePlot: CPTBarPlot!
    var incomePlot: CPTBarPlot!
    var balancePlot: CPTBarPlot!
    
    var timeScope: String?
    var expenseList: [Decimal]?
    var incomeList: [Decimal]?
    
    private let BarWidth = 0.25
    private let BarInitialX = 0.25
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initPlot()
    }
    
    private func initPlot() {
        configureHostView()
        configureGraph()
        configureChart()
        configureAxes()
    }
    
    private func configureHostView() {
        hostView.allowPinchScaling = false
    }
    
    private func configureGraph() {
        // 1 - Create the graph
        let graph = CPTXYGraph(frame: hostView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        hostView.hostedGraph = graph
        
        // 2 - Configure the graph
        graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        graph.plotAreaFrame?.borderLineStyle = nil
        graph.fill = CPTFill(color: CPTColor.clear())
        graph.paddingBottom = 30.0
        graph.paddingLeft = 60.0
        graph.paddingTop = 30.0
        graph.paddingRight = 30.0
        
        // 3 - Set up styles
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 20.0
        titleStyle.textAlignment = .center
        graph.titleTextStyle = titleStyle
        
        let title = "Trend for \(timeScope!)"
        graph.title = title
        graph.titlePlotAreaFrameAnchor = .top
        graph.titleDisplacement = CGPoint(x: 0.0, y: -16.0)
        
        // 4 - Set up plot space
        let xMin = 0.0
        let xMax = Double(expenseList!.count)
        let yMin = 0.0
        let yMax = ((1.4 * max(expenseList!.max()!, incomeList!.max()!)) as NSDecimalNumber).doubleValue
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
    }
    
    private func configureChart() {
        // 1 - Set up the three plots
        expensePlot = CPTBarPlot()
        expensePlot.fill = CPTFill(color: CPTColor(componentRed:0.92, green:0.28, blue:0.25, alpha:1.00))
        incomePlot = CPTBarPlot()
        incomePlot.fill = CPTFill(color: CPTColor(componentRed:0.06, green:0.80, blue:0.48, alpha:1.00))
        balancePlot = CPTBarPlot()
        balancePlot.fill = CPTFill(color: CPTColor(componentRed:0.22, green:0.33, blue:0.49, alpha:1.00))
        
        // 2 - Set up line style
        let barLineStyle = CPTMutableLineStyle()
        barLineStyle.lineColor = CPTColor.lightGray()
        barLineStyle.lineWidth = 0.5
        
        // 3 - Add plots to graph
        guard let graph = hostView.hostedGraph else { return }
        var barX = BarInitialX
        let plots = [expensePlot!, incomePlot!, balancePlot!]
        for plot: CPTBarPlot in plots {
            plot.dataSource = self
            plot.delegate = self
            plot.barWidth = NSNumber(value: BarWidth)
            plot.barOffset = NSNumber(value: barX)
            plot.lineStyle = barLineStyle
            graph.add(plot, to: graph.defaultPlotSpace)
            barX += BarWidth
        }
    }
    
    private func configureAxes() {
        // 1 - Configure styles
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.black()
        // 2 - Get the graph's axis set
        guard let axisSet = hostView.hostedGraph?.axisSet as? CPTXYAxisSet else { return }
        // 3 - Configure the x-axis
//        if let xAxis = axisSet.xAxis {
//            xAxis.labelingPolicy = .none
//            xAxis.majorIntervalLength = 1
//            xAxis.axisLineStyle = axisLineStyle
//            var majorTickLocations = Set<NSNumber>()
//            var axisLabels = Set<CPTAxisLabel>()
//            for (idx, rate) in rates.enumerated() {
//                majorTickLocations.insert(NSNumber(value: idx))
//                let label = CPTAxisLabel(text: "\(rate.date)", textStyle: CPTTextStyle())
//                label.tickLocation = NSNumber(value: idx)
//                label.offset = 5.0
//                label.alignment = .left
//                axisLabels.insert(label)
//            }
//            xAxis.majorTickLocations = majorTickLocations
//            xAxis.axisLabels = axisLabels
//        }
        // 4 - Configure the y-axis
        if let yAxis = axisSet.yAxis {
            yAxis.labelingPolicy = .fixedInterval
            let yMax = ((1.4 * max(expenseList!.max()!, incomeList!.max()!)) as NSDecimalNumber).doubleValue
            yAxis.majorIntervalLength = pow(10, Double(Int(log10(yMax)))) / 2.0 as NSNumber
            yAxis.labelOffset = -10.0
            yAxis.majorTickLength = 30
            let majorTickLineStyle = CPTMutableLineStyle()
            majorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.1)
            yAxis.majorTickLineStyle = majorTickLineStyle
            yAxis.minorTickLength = 20
            let minorTickLineStyle = CPTMutableLineStyle()
            minorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.05)
            yAxis.minorTickLineStyle = minorTickLineStyle
            yAxis.axisLineStyle = axisLineStyle
        }
    }
    
}

extension BarChartViewController: CPTBarPlotDataSource, CPTBarPlotDelegate {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(expenseList!.count)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        if fieldEnum == UInt(CPTBarPlotField.barTip.rawValue) {
            if plot == expensePlot {
                return expenseList![Int(idx)]
            }
            if plot == incomePlot {
                return incomeList![Int(idx)]
            }
            if plot == balancePlot {
                return incomeList![Int(idx)] - expenseList![Int(idx)]
            }
        }
        return idx
    }
    
    func barPlot(_ plot: CPTBarPlot, barWasSelectedAtRecord idx: UInt, with event: UIEvent) {
        
    }
}
