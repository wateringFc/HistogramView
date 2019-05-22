//
//  ViewController.swift
//  HistogramView
//
//  Created by FC on 2019/5/21.
//  Copyright © 2019年 JKB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .gray
        
        
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let xValuesArr = ["title_0", "title_1", "title_2", "title_3", "title_4", "title_5", "title_6", "title_7", "title_8", "title_9", "title_10", "title_11", "title_12", "title_13"]
        let yValuesArr = ["85", "209", "185", "395", "500", "260", "136", "150", "78", "10", "310", "520", "190", "355"]
        let histogramView = FCHistogramView(frame: CGRect(x: 0, y: 88, width: view.width, height: 400), xValues: xValuesArr, yValues: yValuesArr, barW: 25, gapW: 20, yScaleV: 100, yAxisNum: 6, unitStr: "Kg", barBgCorlor: .blue)
        histogramView.backgroundColor = .white
        histogramView.maxVlue = 200
        histogramView.isShowEachYValus = true
        view.addSubview(histogramView)
    }

}

