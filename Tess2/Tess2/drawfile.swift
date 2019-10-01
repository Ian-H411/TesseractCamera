//
//  drawfile.swift
//  Tess2
//
//  Created by Ian Hall on 10/1/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//


import Foundation
import UIKit

class Draw: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let color:UIColor = UIColor.red

        let bpath:UIBezierPath = UIBezierPath(rect: rect)
        bpath.lineWidth = 8
        UIColor.clear.setFill()
        bpath.fill()
        color.set()
        bpath.stroke()

        print("it ran")

        NSLog("drawRect has updated the view")

    }

}
