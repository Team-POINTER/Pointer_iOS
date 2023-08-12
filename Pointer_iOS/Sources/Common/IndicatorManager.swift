//
//  PointerIndicator.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/11.
//

import UIKit
import NVActivityIndicatorView

class IndicatorManager: NSObject {
    
    public static let shared = IndicatorManager()
    
    var bgView: UIView?
    var indicator: NVActivityIndicatorView?
    var isAnimating: Bool = false
    
    private var limitSec = 60
    private let size: CGFloat = 44.0
    private var outTimer: Timer?
 
    private override init() {
        super.init()
        let screenBounds = UIScreen.main.bounds
        let indicatorRect = CGRect(x: CGFloat((screenBounds.width - self.size)/2),
                                   y: CGFloat((screenBounds.height - self.size)/2),
                                   width: self.size,
                                   height: self.size)
        
        self.bgView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: screenBounds.width, height: screenBounds.height))
        self.bgView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        self.bgView?.alpha = 0.0
        self.indicator = NVActivityIndicatorView.init(frame: indicatorRect, type: .lineSpinFadeLoader, color: UIColor.gray, padding: 0.0)
        self.bgView?.addSubview(self.indicator!)
        
    }
    
    func show(_ view: UIView? = nil, _ limitSec: Int = 60) {
        guard (self.bgView != nil && self.indicator != nil) else { return }
        
        guard self.isAnimating == false else {
            self.refreshTimer()
            return
        }
        
        self.limitSec = limitSec
        
        self.isAnimating = true
        self.indicator!.startAnimating()
        
        if (self.bgView?.superview != nil) {
            self.bgView?.alpha = 0.0
            self.bgView?.removeFromSuperview()
        }
        
        if (view != nil) {
            view?.addSubview(self.bgView!)
        } else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            window?.addSubview(self.bgView!)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.bgView?.alpha = 1.0
        }, completion:nil)
        
        self.startTimer(limitSec)
    }
    
    @objc
    func hide() {
        self.isAnimating = false
        guard (self.bgView != nil && self.indicator != nil) else { return }
        self.indicator!.stopAnimating()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.bgView?.alpha = 0.0
        }, completion: { (complete) in
            self.bgView?.removeFromSuperview()
        })
        
        self.stopTimer()
    }
    
    private func startTimer(_ limitSec: Int) {
        if outTimer != nil {
            stopTimer()
        }
        
        outTimer = Timer.scheduledTimer(timeInterval: TimeInterval(limitSec),
                                             target: self,
                                             selector: #selector(hide),
                                             userInfo: nil,
                                             repeats: false)
        
    }
    
    private func stopTimer() {
        guard outTimer != nil else { return }
        
        outTimer?.invalidate()
        outTimer = nil
    }
    
    private func refreshTimer() {
        stopTimer()
        startTimer(limitSec)
    }
}
