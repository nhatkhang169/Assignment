//
//  UISearchController+Extensions.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import UIKit

extension UISearchController {
    func hideResultView() {
        searchResultsController?.view.isHidden = true
    }
    
    func showResultView() {
        searchResultsController?.view.isHidden = false
    }
}
