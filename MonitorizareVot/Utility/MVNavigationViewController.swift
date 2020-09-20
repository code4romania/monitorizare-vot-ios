//
//  MVNavigationViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 20/09/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class MVNavigationViewController: UINavigationController {
    
    var shouldHideBackButtonTitle: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
}

extension MVNavigationViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if shouldHideBackButtonTitle {
            DispatchQueue.main.async {
                let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                viewController.navigationItem.backBarButtonItem = item
            }
        }
    }
}
