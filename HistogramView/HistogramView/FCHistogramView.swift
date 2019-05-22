//
//  FCHistogramView.swift
//  HistogramView
//
//  Created by FC on 2019/5/21.
//  Copyright © 2019年 JKB. All rights reserved.
//

import UIKit

class FCHistogramView: UIView {
    /// x轴的值数组
    var xValueArr: [String]?
    /// y轴的值数组
    var yValueArr: [String]?
    /// 柱形条的宽度
    var barWidth: CGFloat = 20
    /// 间隔宽度
    var gapWidth: CGFloat = 20
    /// y轴的刻度值
    var yScaleValue: CGFloat = 50
    /// y轴刻度的个数
    var yAxisCount: Int = 10
    /// 单位
    var unit: String?
    /// 柱形图的填充颜色
    var barCorlor: UIColor = .green
    
//-----------------可配置属性-----------------
    /// 是否显示每个y值， 默认显示
    var isShowEachYValus: Bool = true
    /// 是否设置最大值，默认不设置（如大于0则红色显示）
    var maxVlue: CGFloat = 0
    /// 是否显示虚线， 默认为显示
    var isShowDotted: Bool = true
    /// 设置虚线颜色，默认为红色
    var dottedLineColor: UIColor = .red
//-----------------外部可配置属性-----------------
    
    /// 总宽度
    var _totalWidth: CGFloat?
    /// 总高度
    var _totalHeight: CGFloat?
    /// 刻度layer
    var _lineLayer: CAShapeLayer?
    
    /// x轴柱状图 开始 点数组
    fileprivate lazy var barsStartPointsArr = NSMutableArray()
    /// x轴柱状图 结束 点数组
    fileprivate lazy var barsEndPointsArr = NSMutableArray()
    /// 柱状图层数组
    fileprivate lazy var barsLayersArr = NSMutableArray()
    /// 滑动视图
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        return scrollView
    }()
    /// 显示内容视图
    fileprivate lazy var contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    /// 显示单位标签
    fileprivate lazy var unitLab: UILabel = {
        let unitLab = UILabel()
        unitLab.font = UIFont.init(name: "Helvetica-Bold", size: 10)
        return unitLab
    }()
    
    /// 初始化
    init(frame: CGRect, xValues: [String], yValues: [String], barW: CGFloat, gapW: CGFloat, yScaleV: CGFloat, yAxisNum: Int, unitStr: String, barBgCorlor: UIColor) {
        super.init(frame: frame)
        // 属性赋值
        xValueArr = xValues
        yValueArr = yValues
        barWidth = barW
        gapWidth = gapW
        yScaleValue = yScaleV
        yAxisCount = yAxisNum
        unit = unitStr
        barCorlor = barBgCorlor
        unitLab.text = "单位：\(unitStr)"
        // 添加控件
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(unitLab)
//        contentView.addSubview(unitLab)
        // 添加手势
        contentViewAddTap()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 滑动视图
        scrollView.frame = bounds
        // 单位标签
        unitLab.frame = CGRect(x: 5, y: 5, width: 60, height: 20)
        // 总宽度
        _totalWidth = gapWidth + (barWidth + gapWidth) * CGFloat(xValueArr!.count)
        // 总高度
        _totalHeight = scrollView.height - 25 - 10 - 40
        // 设置滑动范围
        scrollView.contentSize = CGSize(width: 30 + _totalWidth!, height: 0)
        // 设置内容视图
        contentView.frame = CGRect(x: 30, y: 40, width: _totalWidth!, height: _totalHeight!)
        // 绘制柱状图
        drawHistogramView()
    }
}

// MARK: - 关键步骤
extension FCHistogramView {
    /// 第一步：触发重新布局，清除之前视图，确保不重叠
    fileprivate func clearView() {
        // 删除起始点
        barsStartPointsArr.removeAllObjects()
        barsEndPointsArr.removeAllObjects()
        
        // 删除绘制矩形图层
        for layer in barsLayersArr {
            (layer as! CAShapeLayer).removeFromSuperlayer()
        }
        barsLayersArr.removeAllObjects()
        _lineLayer?.removeFromSuperlayer()
        _lineLayer = nil
        
        // 除了单位标签保留其它删除
        for view in contentView.subviews {
            if view.isEqual(unitLab) {
                continue
            }else {
                view.removeFromSuperview()
            }
        }
    }
    
    /// 第二步：绘制坐标轴
    fileprivate func drawAxis() {
        let path = UIBezierPath()
        // 画x.y坐标线
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: _totalHeight!))
        path.addLine(to: CGPoint(x: _totalWidth!, y: _totalHeight!))
        // 画左上角的箭头
        path.move(to: CGPoint(x: -5, y: 5))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 5, y: 5))
        // 画右上角的箭头
        path.move(to: CGPoint(x: _totalWidth! - 5, y: _totalHeight! - 5))
        path.addLine(to: CGPoint(x: _totalWidth!, y: _totalHeight!))
        path.addLine(to: CGPoint(x: _totalWidth! - 5, y: _totalHeight! + 5))
        
        // 画y轴刻度
        for i in 0..<yAxisCount {
            if isShowDotted {
                // 绘制背景虚线
                let lineView = UIView(frame: CGRect(x: 10, y: CGFloat(i)*(_totalHeight!/CGFloat(yAxisCount)), width: _totalWidth!, height: 1))
                lineView.alpha = 0.7
                contentView.addSubview(lineView)
                drawDashLine(lineView: lineView, lineLength: 5, lineSpacing: 5, lineColor: dottedLineColor)
            }
            
            // 绘制y轴的刻度
            path.move(to: CGPoint(x: 0, y: CGFloat(i)*(_totalHeight!/CGFloat(yAxisCount))))
            path.addLine(to: CGPoint(x: 5, y: CGFloat(i)*(_totalHeight!/CGFloat(yAxisCount))))
        }
        
        // 画x轴的刻度
        for i in 0..<xValueArr!.count {
            let startPoint = CGPoint(x: CGFloat(i) * (barWidth + gapWidth) + gapWidth + barWidth/2, y: _totalHeight!)
            let value = NSValue.init(cgPoint: startPoint)
            barsStartPointsArr.add(value)
            path.move(to: startPoint)
            path.addLine(to: CGPoint(x: CGFloat(i) * (barWidth + gapWidth) + gapWidth + barWidth/2, y: _totalHeight!-5))
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = UIColor.gray.cgColor
        lineLayer.lineWidth = 1
        lineLayer.path = path.cgPath
        lineLayer.fillColor = UIColor.clear.cgColor
        contentView.layer.addSublayer(lineLayer)
        _lineLayer = lineLayer
    }
    
    /// 第三步：给y轴添加刻度显示文字
    fileprivate func addYAxisLabs() {
        for i in 0...yAxisCount {
            // 获取到刻度值
            let yAxis = yScaleValue * CGFloat(i)
            let label = UILabel(frame: CGRect(x: -5, y: CGFloat((yAxisCount - i)) * (_totalHeight!/CGFloat(yAxisCount)) - 10, width: -25, height: 20))
            let str = ("\(yAxis)")
            let strArr:[Substring] = str.split(separator: ".")
            label.text = ("\(strArr[0])")
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .right
            contentView.addSubview(label)
        }
    }
    
    /// 第四步：给x轴添加刻度显示
    fileprivate func addXAxisLabs() {
        for i in 0..<xValueArr!.count {
            let point = (barsStartPointsArr[i] as AnyObject).cgPointValue
            
            let label = UILabel()
            label.bounds =  CGRect(x: 0, y: 0, width: barWidth + gapWidth*4/5, height: 20)
            label.center = CGPoint(x: point!.x, y: point!.y + label.height/2)
            label.text = "\(xValueArr![i])"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 10)
            contentView.addSubview(label)
        }
    }
    
    /// 第五步：绘制矩形
    fileprivate func addHistograms() {
        for i in 0..<yValueArr!.count {
            let str = "\(yValueArr![i])"
            let y = CGFloat(Double(str)!)
            // 算出每个矩形的高度
            let barHeight:CGFloat = y / (CGFloat(yAxisCount) * yScaleValue) * _totalHeight!
            // 计算起始点
            let startPoint = (barsStartPointsArr[i] as AnyObject).cgPointValue
            let endPoint = CGPoint(x: startPoint!.x, y: startPoint!.y - barHeight)
            // 每个矩形的结束点添加到数组中
            let value = NSValue.init(cgPoint: endPoint)
            barsEndPointsArr.add(value)
            // 绘制矩形
            let barLayer = CAShapeLayer()
            // 如设置最大值，超过最大值则显示红色
            if maxVlue > 0 && y > maxVlue {
                barLayer.strokeColor = UIColor.red.cgColor
            }else {
                barLayer.strokeColor = barCorlor.cgColor
            }
            
            barLayer.lineWidth = barWidth;
            contentView.layer.addSublayer(barLayer)
            
            let barPath = UIBezierPath()
            barPath.move(to: startPoint!)
            barPath.addLine(to: endPoint)
            barPath.close()
            barLayer.path = barPath.cgPath
            // 添加显示动画
            barLayer.add(animationWithDuration(duration: 0.5*Double((i+1))), forKey: nil)
            // 添加所有图层到数组
            barsLayersArr.add(barLayer)
        }
    }
    
    /// 第六步：显示矩形上的数字（可选）
    fileprivate func showHistogramsYValus() {
        if !isShowEachYValus { return }
        for i in 0..<xValueArr!.count {
            let point = (barsEndPointsArr[i] as AnyObject).cgPointValue
            let label = UILabel()
            label.bounds =  CGRect(x: 0, y: 0, width: barWidth + gapWidth*4/5, height: 20)
            label.center = CGPoint(x: point!.x, y: point!.y - 10)
            label.textColor = barCorlor
            label.text = "\(yValueArr![i])"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 10)
            contentView.addSubview(label)
        }
    }
}

extension FCHistogramView {
    /// 绘制柱状图
    fileprivate func drawHistogramView() {
        clearView()
        drawAxis()
        addYAxisLabs()
        addXAxisLabs()
        addHistograms()
        showHistogramsYValus()
    }
    
    /// 添加手势
    fileprivate func contentViewAddTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(click(tap:)))
        contentView.addGestureRecognizer(tap)
    }
    
    /// 实现手势方法
    @objc func click(tap: UITapGestureRecognizer) {
        let point = tap.location(in: contentView)
        for i in 0..<barsStartPointsArr.count {
            // 获取到柱状图的起始点
            let startPoint = (barsStartPointsArr[i] as AnyObject).cgPointValue
            let endPoint = (barsEndPointsArr[i] as AnyObject).cgPointValue
            // 根据起始点来判断是否点击了矩形
            if point.x >= startPoint!.x - barWidth/2 &&
                point.x <= startPoint!.x + barWidth/2 &&
                point.y >= endPoint!.y && point.y <= startPoint!.y {
                print("点击了第\(i)个矩形")
            }
        }
    }
    
    /// 绘制虚线
    fileprivate func drawDashLine(lineView: UIView, lineLength:Int, lineSpacing:Int, lineColor:UIColor) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = lineView.bounds
        shapeLayer.position = CGPoint(x:lineView.width/2 , y: lineView.height)
        shapeLayer.fillColor = UIColor.clear.cgColor
        // 设置虚线颜色
        shapeLayer.strokeColor = lineColor.cgColor
        // 设置虚线宽度
        shapeLayer.lineWidth = lineView.height
        shapeLayer.lineJoin = kCALineJoinRound
        // 设置线宽、线间距
        shapeLayer.lineDashPattern = [lineLength, lineSpacing] as [NSNumber]
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: lineView.width, y: 0))
        shapeLayer.path = path
        lineView.layer.addSublayer(shapeLayer)
    }
    
    /// 添加动画
    fileprivate func animationWithDuration(duration: CFTimeInterval) -> (CABasicAnimation) {
        let anmiation = CABasicAnimation(keyPath: "strokeEnd")
        anmiation.timingFunction = CAMediaTimingFunction(name: "easeOut")
        anmiation.duration = duration
        anmiation.fromValue = 0
        anmiation.toValue = 1
        return anmiation;
    }
}
