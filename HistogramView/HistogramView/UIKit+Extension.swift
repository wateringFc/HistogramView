//
//  UIKit+Extension.swift
//  Manage
//
//  Created by FC on 2019/5/6.
//  Copyright © 2019年 JKB. All rights reserved.
//

import UIKit
import CoreText

protocol StoryboardLoadable {}
extension StoryboardLoadable where Self: UIViewController {
    /// 提供 加载方法
    static func loadStoryboard() -> Self {
        return UIStoryboard(name: "\(self)", bundle: nil).instantiateViewController(withIdentifier: "\(self)") as! Self
    }
}

/** 加载本地nib协议 */
protocol NibLoadable {}
extension NibLoadable {
    static func loadViewFromNib() -> Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! Self
    }
}

extension UIView {
    /// x
    var x: CGFloat {
        get { return frame.origin.x }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.x    = newValue
            frame                 = tempFrame
        }
    }
    
    /// y
    var y: CGFloat {
        get { return frame.origin.y }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.y    = newValue
            frame                 = tempFrame
        }
    }
    
    /// height
    var height: CGFloat {
        get { return frame.size.height }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.height = newValue
            frame                 = tempFrame
        }
    }
    
    /// width
    var width: CGFloat {
        get { return frame.size.width }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.width  = newValue
            frame = tempFrame
        }
    }
    
    /// size
    var size: CGSize {
        get { return frame.size }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size        = newValue
            frame                 = tempFrame
        }
    }
    
    /// centerX
    var centerX: CGFloat {
        get { return center.x }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.x            = newValue
            center                  = tempCenter
        }
    }
    
    /// centerY
    var centerY: CGFloat {
        get { return center.y }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.y            = newValue
            center                  = tempCenter;
        }
    }
    
    /// 部分圆角
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func fc_corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /// 添加单击手势
    func fc_addTarget(target: AnyObject, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }
}

protocol RegisterCellFromNib {}
/** 注册nibcell */
extension RegisterCellFromNib {
    static var identifier: String { return "\(self)" }
    static var nib: UINib? { return UINib(nibName: "\(self)", bundle: nil) }
}

extension UITableView {
    /// 注册 cell 的方法
    func fc_registerCell<T: UITableViewCell>(cell: T.Type) where T: RegisterCellFromNib {
        if let nib = T.nib { register(nib, forCellReuseIdentifier: T.identifier) }
        else { register(cell, forCellReuseIdentifier: T.identifier) }
    }
    
    /// 从缓存池池出队已经存在的 cell
    func fc_dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: RegisterCellFromNib {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
}


extension UIImageView {
    /// 设置图片圆角
    func circleImage() {
        /// 建立上下文
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        /// 获取当前上下文
        let ctx = UIGraphicsGetCurrentContext()
        /// 添加一个圆，并裁剪
        ctx?.addEllipse(in: self.bounds)
        ctx?.clip()
        /// 绘制图像
        self.draw(self.bounds)
        /// 获取绘制的图像
        let image = UIGraphicsGetImageFromCurrentImageContext()
        /// 关闭上下文
        UIGraphicsEndImageContext()
        DispatchQueue.global().async {
            self.image = image
        }
    }
}

extension UIButton {
    
    /// 倒计时按钮
    ///
    /// - Parameters:
    ///   - totalTime: 总时间
    ///   - duringText: 进行时拼接文字
    ///   - duringColor: 进行时文字颜色
    ///   - againText: 重新获取文字
    ///   - againColor: 重新获取文字颜色
    func sendCodeBut(totalTime: Int, duringText: String, duringColor: UIColor, againText: String, againColor: UIColor) {
        //先让按钮不能点
        self.isUserInteractionEnabled = false
        var time = totalTime
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        // 开始时间，时间间隔
        timer.schedule(wallDeadline: .now(), repeating: 1)
        // 每个时间段执行的方法
        timer.setEventHandler {
            time -= 1
            // 回到主线程更新按钮标题
            DispatchQueue.main.sync(execute: {
                self.setTitle("\(time)\(duringText)", for: .normal)
                self.setTitleColor(duringColor, for: .normal)
            })
            
            // 倒计时到0时，设置默认标题，打开用户交互，取消定时任务
            if time == 0 {
                // 回到主线程刷新UI
                DispatchQueue.main.sync(execute: {
                    self.setTitle(againText, for: .normal)
                    self.setTitleColor(againColor, for: .normal)
                    self.isUserInteractionEnabled = true
                })
                timer.cancel()
            }
        }
        //开启定时器
        timer.resume()
    }
}

extension String {
    /// 正则匹配手机号
    var isPhone: Bool {
        /**
         * 手机号码
         * 移动：134 135 136 137 138 139 147 148 150 151 152 157 158 159  165 172 178 182 183 184 187 188 198
         * 联通：130 131 132 145 146 155 156 166 171 175 176 185 186
         * 电信：133 149 153 173 174 177 180 181 189 199
         * 虚拟：170
         */
        return isMatch("^(1[3-9])\\d{9}$")
    }
    
    /// 正则匹配用户身份证号15或18位
    var isUserIdCard: Bool {
        return isMatch("(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)")
    }
    
    /// 正则匹配用户密码6-18位数字和字母组合
    var isPassword: Bool {
        return isMatch("^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,18}")
    }
    
    /// 正则匹配URL
    var isURL: Bool {
        return isMatch("^[0-9A-Za-z]{1,50}")
    }
    
    /// 正则匹配用户姓名,10位的中文或英文
    var isUserName: Bool {
        return isMatch("^[a-zA-Z\\u4E00-\\u9FA5]{1,10}")
    }
    
    /// 正则匹配公司名称,20位的中文或英文
    var isCompanyName: Bool {
        return isMatch("^[a-zA-Z\\u4E00-\\u9FA5]{1,20}")
    }
    
    /// 正则匹配用户email
    var isEmail: Bool {
        return isMatch("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
    }
    
    /// 判断是否都是数字
    var isNumber: Bool {
        return isMatch("^[0-9]*$")
    }
    
    /// 判断是否4位数验证码
    var isCode: Bool {
        return isMatch("^[0-9]{4}$")
    }
    /// 只能输入由26个英文字母组成的字符串
    var isLetter: Bool {
        return isMatch("^[A-Za-z]+$")
    }
    
    private func isMatch(_ pred: String ) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", pred)
        let isMatch: Bool = pred.evaluate(with: self)
        return isMatch
    }
    
    /// NSRange转RangeExpression
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
    
    /// 身份证号生日隐藏
    func idCardToAsterisk() -> (String) {
        let range = NSMakeRange(6, 8)
        let rag = self.toRange(range)
        let results: String = self.replacingCharacters(in: rag!, with: "********")
        return results
    }
    
    /// 名字最后一位隐藏
    func userNameToAsterisk() -> (String) {
        let range = NSMakeRange(self.count-1, 1)
        let rag = self.toRange(range)
        let results: String = self.replacingCharacters(in: rag!, with: "*")
        return results
    }
    
    /// 手机号中间4位隐藏
    func phoneToAsterisk() -> (String) {
        let length = self.count
        var range = NSMakeRange(0, 0)
        if length == 11 {
            range = NSMakeRange(3, length-7)
        }else if length >= 5 && length < 11 {
            range = NSMakeRange(3, length-3)
        }else {
            range = NSMakeRange(1, length-1)
        }
        let rag = self.toRange(range)
        return self.replacingCharacters(in: rag!, with: "****")
    }
}

