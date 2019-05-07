//
//  LoadingView.swift
//  RandomNumber
//
//  Created by ljy on 07/05/2019.
//  Copyright © 2019 ljy. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    static let shared:LoadingView = {
        let instance = LoadingView()
        return instance
    }()
    
    var indicator:UIActivityIndicatorView!
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        let frame = UIScreen.main.bounds
        
        let bg = UIView()
        bg.backgroundColor = UIColor.black
        bg.alpha = 0.5
        bg.frame = frame
        self.addSubview(bg)
        
        indicator = UIActivityIndicatorView(style: .whiteLarge)
        self.addSubview(indicator)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let frame = UIScreen.main.bounds
        indicator.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    }
    
    func show(){
        let app = UIApplication.shared.delegate as! AppDelegate
        app.window?.bringSubviewToFront(self)
        self.isHidden = false
        indicator.startAnimating()
    }
    
    func hide(){
        self.isHidden = true
        indicator.stopAnimating()
    }

}
