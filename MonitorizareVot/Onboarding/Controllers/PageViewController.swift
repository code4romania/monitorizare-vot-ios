//
//  PageViewController.swift
//  MonitorizareVot
//
//  Created by Geart Otten on 12/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SnapKit

class PageViewController: UIPageViewController {

    // MARK: Variables
    
    lazy var viewControllerList: [UIViewController] = {
        var viewControllers: [UIViewController] = []
        viewControllers.append(VotingStationViewController())
        viewControllers.append(FormsViewController())
        viewControllers.append(AddNotesViewController())
        return viewControllers
    }()
    
    private lazy var openAppButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.setTitle("Onboarding_Button_Go_To_App".localized, for: .normal)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchDown)
        button.setTitleColor(.gray, for: .highlighted)
        button.isHidden = true
        return button
    }()
    
    var pageControl: UIPageControl!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        
        if let firstViewController = viewControllerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
        }
        
        self.dataSource = self
        self.delegate = self
        configurePageControl()
        
    }
    
    func setupConstraints() {
        openAppButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(pageControl)
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = viewControllerList.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor(red: 0.21, green: 0.13, blue: 0.27, alpha: 0.35)
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 0.21, green: 0.13, blue: 0.27, alpha: 1)
        self.view.addSubview(pageControl)
        self.view.addSubview(openAppButton)
        setupConstraints()
    }
    
    @objc
    func nextButtonTapped(){
        let sectieViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SectieViewController")
        self.navigationController?.setViewControllers([sectieViewController], animated: true)
    }

}

// MARK: PageViewControllerDataSource & Delegate

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        
        let prevIndex = vcIndex - 1
        
        guard prevIndex >= 0 else { return nil }
        
        guard viewControllerList.count > prevIndex else { return nil }
        
        return viewControllerList[prevIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = vcIndex + 1
        
        guard viewControllerList.count != nextIndex else { return nil }
        guard viewControllerList.count > nextIndex else { return nil}
        
        return viewControllerList[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = viewControllerList.firstIndex(of: pageContentViewController)!
        if self.pageControl.currentPage == viewControllerList.count-1 {
            openAppButton.isHidden = false
        } else {
            openAppButton.isHidden = true
        }
    }
}
