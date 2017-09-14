//
//  PopVC.swift
//  WhatIsThere
//
//  Created by Fomin Mykola on 9/14/17.
//  Copyright © 2017 Fomin Mykola. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    var passedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        addDoubleTap()
    }

    func initData(forImage image: UIImage) {
        self.passedImage = image
    }
    
    func addDoubleTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

}
