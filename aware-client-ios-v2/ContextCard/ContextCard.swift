//
//  ContextCardView.swift
//  Vita
//
//  Created by Yuuki Nishiyama on 2018/06/22.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import Charts
import AWAREFramework

@IBDesignable class ContextCard: UIView {

    @IBOutlet weak var baseStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var spaceView: UIView!
    @IBOutlet weak var indicatorHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigatorView: UIStackView!
    @IBOutlet weak var navigatorTitleButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    var backwardHandler:(()->Void)?
    var forwardHandler:(()->Void)?
    var navigatorTitleButtonHandler:(()->Void)?
    
    var currentDate = Date()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aCoder: NSCoder) {
        super.init(coder: aCoder)!
        setup()
    }
    
    func setup() {
        let view = Bundle.main.loadNibNamed("ContextCard", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        let height = frame.height - titleLabel.frame.height - spaceView.frame.height
        indicatorHeightLayoutConstraint.isActive = false
        self.heightAnchor.constraint(equalToConstant:height).isActive = true
        // indicatorView.frame = CGRect(x:0, y:0, width:frame.width, height:height)
        
        currentDate = Date()
        self.setTitleToNavigationView(with: currentDate)
    }
    
    public func setTitleToNavigationView(with date:Date){
        self.currentDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)
        navigatorTitleButton.setTitle(dateString, for: .normal)
    }
    
    public func setTitleToNavigationView(with string:String){
        navigatorTitleButton.setTitle(string, for: .normal)
    }
    
    
    @IBAction func pushedNavigatorTitleButton(_ sender: Any) {
        if let handler = navigatorTitleButtonHandler {
            handler()
        }
    }
    
    @IBAction func pushedBackwardButton(_ sender: UIButton) {
        if let handler = backwardHandler {
            handler()
        }
    }
    
    @IBAction func pushedForwardButton(_ sender: UIButton) {
        if let handler = forwardHandler {
            handler()
        }
    }
    
    
}
