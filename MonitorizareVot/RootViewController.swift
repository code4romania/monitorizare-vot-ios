//  Created by Code4Romania

import UIKit
import SafariServices

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = MVColors.black.color
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let guideButton = UIBarButtonItem(image: UIImage(named:"guideIcon"), style: .plain, target: self, action: #selector(RootViewController.pushGuideViewController))
        let callButton = UIBarButtonItem(image: UIImage(named:"callIcon"), style: .plain, target: self, action: #selector(RootViewController.performCall))
        self.navigationItem.rightBarButtonItems = [callButton, guideButton]
    }
    
    @objc func pushGuideViewController() {
        if let url = URL(string: "http://monitorizare-vot-ghid.azurewebsites.net/") {
            let safariViewController = SFSafariViewController(url: url)
            self.navigationController?.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    @objc func performCall() {
        let phoneCallPath = "telprompt://0800080200"
        if let phoneCallURL = NSURL(string: phoneCallPath) {
            UIApplication.shared.openURL(phoneCallURL as URL)
        }
    }

}
