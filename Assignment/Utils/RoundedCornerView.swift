//
//  RoundedCornerView.swift
//  Assignment
//
//  Created by azun on 21/03/2022.
//

import UIKit

class RoundedCornerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        roundCorners()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        roundCorners()
    }
    
    private func roundCorners() {
        clipsToBounds = true
        layer.cornerRadius = 8
    }
}
