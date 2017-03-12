//
//  BarChartViewController.swift
//  AccountBook
//
//  Created by yang on 3/11/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CorePlot

class BarChartViewController: UIViewController {
    @IBOutlet var hostView: CPTGraphHostingView!
    var expensePlot: CPTBarPlot!
    var incomePlot: CPTBarPlot!
}

extension BarChartViewController: CPTBarPlotDataSource, CPTBarPlotDelegate {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return 0
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        return 0
    }
    
    func barPlot(_ plot: CPTBarPlot, barWasSelectedAtRecord idx: UInt, with event: UIEvent) {
        
    }
}
