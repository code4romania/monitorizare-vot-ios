//
//  UITableView+HeaderAutoLayout.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 04/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

extension UITableView {
 
    //Variable-height UITableView tableHeaderView with autolayout
    func layoutTableHeaderView() {
     
        guard let headerView = self.tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false
         
        let headerWidth = headerView.bounds.size.width;
        let temporaryWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[headerView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: UInt(0)), metrics: ["width": headerWidth], views: ["headerView": headerView])
         
        headerView.addConstraints(temporaryWidthConstraints)
         
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
         
        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame
         
        frame.size.height = height
        headerView.frame = frame
         
        self.tableHeaderView = headerView
         
        headerView.removeConstraints(temporaryWidthConstraints)
        headerView.translatesAutoresizingMaskIntoConstraints = true
         
    }
}
