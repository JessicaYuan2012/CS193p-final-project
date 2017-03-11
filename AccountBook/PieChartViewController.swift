//
//  PieChartViewController.swift
//  AccountBook
//
//  Created by yang on 3/10/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CorePlot

// Cite: https://www.raywenderlich.com/131985/core-plot-tutorial-getting-started
class PieChartViewController: UIViewController {
    @IBOutlet weak var hostView: CPTGraphHostingView!
    
    // public API
    var transactionType: String?
    var timeScope: String? // "Month" or "All"
    var categoryAmountTupleList: [(String, Decimal)]?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if categoryAmountTupleList != nil {
            initPlot()
        }
    }
    
    private func initPlot() {
        configureHostView()
        configureGraph()
        configureChart()
        configureLegend()
    }
    
    private func configureHostView() {
        hostView.allowPinchScaling = false
    }
    
    private func configureGraph() {
        // 1 - Create and configure the graph
        let graph = CPTXYGraph(frame: hostView.bounds)
        hostView.hostedGraph = graph
        graph.paddingLeft = 0.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        graph.paddingBottom = 0.0
        graph.axisSet = nil
        
        // 2 - Create text style
        let textStyle: CPTMutableTextStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor.black()
        textStyle.fontName = "HelveticaNeue-Bold"
        textStyle.fontSize = 20.0
        textStyle.textAlignment = .center
        
        // 3 - Set graph title and text style
        if timeScope! == "Month" {
            graph.title = "\(transactionType!) Composition This Month"
        } else {
            graph.title = "All \(transactionType!) Composition"
        }
        
        graph.titleTextStyle = textStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.top
    }
    
    private func configureChart() {
        // 1 - Get a reference to the graph
        let graph = hostView.hostedGraph!
        
        // 2 - Create the chart
        let pieChart = CPTPieChart()
        pieChart.delegate = self
        pieChart.dataSource = self
        pieChart.pieRadius = (min(hostView.bounds.size.width, hostView.bounds.size.height) * 0.7) / 2
        pieChart.identifier = NSString(string: graph.title!)
        pieChart.startAngle = CGFloat(M_PI_4)
        pieChart.sliceDirection = .clockwise
        pieChart.labelOffset = -0.6 * pieChart.pieRadius
        
        // 3 - Configure border style
        let borderStyle = CPTMutableLineStyle()
        borderStyle.lineColor = CPTColor.white()
        borderStyle.lineWidth = 2.0
        pieChart.borderLineStyle = borderStyle
        
        // 4 - Configure text style
        let textStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor.white()
        textStyle.textAlignment = .center
        pieChart.labelTextStyle = textStyle
        
        // 5 - Add chart to graph
        graph.add(pieChart)
    }
    
    private func configureLegend() {
        // 1 - Get graph instance
        guard let graph = hostView.hostedGraph else { return }
        
        // 2 - Create legend
        let theLegend = CPTLegend(graph: graph)
        
        // 3 - Configure legend
        theLegend.numberOfColumns = 1
        theLegend.fill = CPTFill(color: CPTColor.white())
        let textStyle = CPTMutableTextStyle()
        textStyle.fontSize = 12
        theLegend.textStyle = textStyle
        
        // 4 - Add legend to graph
        graph.legend = theLegend
        if view.bounds.width > view.bounds.height {
            graph.legendAnchor = .right
            graph.legendDisplacement = CGPoint(x: -20, y: 0.0)
            
        } else {
            graph.legendAnchor = .bottomRight
            graph.legendDisplacement = CGPoint(x: -8.0, y: 8.0)
        }
    }
}

extension PieChartViewController: CPTPieChartDataSource, CPTPieChartDelegate {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        if categoryAmountTupleList == nil {
            return UInt(0)
        }
        return UInt(categoryAmountTupleList!.count)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        return categoryAmountTupleList![Int(idx)].1
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        let amount = categoryAmountTupleList![Int(idx)].1
        let amountString = getCurrencyString(for: amount)
        let category = categoryAmountTupleList![Int(idx)].0
        let layer = CPTTextLayer(text: "\(category)\n\(amountString)")
        layer.textStyle = plot.labelTextStyle
        return layer
    }
    
    func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
        switch idx {
        case 0:
            return CPTFill(color: CPTColor(componentRed:0.92, green:0.28, blue:0.25, alpha:1.00))
        case 1:
            return CPTFill(color: CPTColor(componentRed:0.06, green:0.80, blue:0.48, alpha:1.00))
        case 2:
            return CPTFill(color: CPTColor(componentRed:0.22, green:0.33, blue:0.49, alpha:1.00))
        case 3:
            return CPTFill(color: CPTColor(componentRed: 1.00, green: 0.80, blue: 0.00, alpha: 1.00))
        case 4:
            return CPTFill(color: CPTColor(componentRed: 0.35, green: 0.34, blue: 0.84, alpha: 1.00))
        default:
            return nil
        }
    }
    
    func legendTitle(for pieChart: CPTPieChart, record idx: UInt) -> String? {
        return categoryAmountTupleList![Int(idx)].0
    }  
}
