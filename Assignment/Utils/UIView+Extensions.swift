//
//  UIView+Extensions.swift
//  Assignment
//
//  Created by azun on 21/03/2022.
//

import UIKit

extension UIView {
    func closeView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseIn) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    func showView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseIn) {
            self.alpha = 1
        }
    }
}
