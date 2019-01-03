//
//  ReaderPageController.swift
//  Settings
//
//  Created by Gary Griswold on 10/29/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class ReaderPagesController : UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    static let NEW_REFERENCE = NSNotification.Name("new-reference")
    static let WEB_LOAD_DONE = NSNotification.Name("web-load-done")
    
    private var readerViewQueue: ReaderViewQueue = ReaderViewQueue()
    //private var pageViewController: PageViewController!
    private var pageViewController: UIPageViewController!
    private var toolBar: ReaderToolbar!
    
    override var prefersStatusBarHidden: Bool { get { return true } }

    override func loadView() {
        super.loadView()
        
        self.toolBar = ReaderToolbar(controller: self)
        let read = NSLocalizedString("Bible", comment: "Button to return to read Bible")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: read, style: .plain, target: nil,
                                                                action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadBiblePage(note:)),
                                               name: ReaderPagesController.NEW_REFERENCE, object: nil)

        // Load the starting page
        NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                        object: HistoryModel.shared.current())
    }
    
    @objc func loadBiblePage(note: NSNotification) {
        let reference = note.object as! Reference
        self.toolBar.loadBiblePage(reference: reference)
        
        if self.pageViewController != nil {
            self.pageViewController.view.removeFromSuperview()
            self.pageViewController.removeFromParent()
        }
        //self.pageViewController = PageViewController()
        self.pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                       navigationOrientation: .horizontal, options: nil)
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        let page1 = self.readerViewQueue.first(reference: reference)
        self.pageViewController.setViewControllers([page1], direction: .forward, animated: true, completion: nil)
        print("Doing setViewController \(reference.toString())")
        
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = self.view.safeAreaLayoutGuide
        self.pageViewController.view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.pageViewController.view.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.pageViewController.view.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.pageViewController.view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        // listen for completion of webView set with content in ReaderViewController
        NotificationCenter.default.addObserver(self, selector: #selector(setViewControllerComplete),
                                               name: ReaderPagesController.WEB_LOAD_DONE, object: nil)
    }
    
    @objc func setViewControllerComplete(note: NSNotification) {
        self.readerViewQueue.preload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = AppFont.backgroundColor
        
        self.toolBar.refresh()
        
        //let hideNavBar = (AppFont.nightMode) ? false : true
        let hideNavBar = true
        self.navigationController?.setNavigationBarHidden(hideNavBar, animated: false)
        self.navigationController?.isToolbarHidden = false
        
        // This only needs to be done when settings are updated, but it only takes 2ms
        self.readerViewQueue.updateCSS()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    //
    // DataSource
    //
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.readerViewQueue.prior(controller: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.readerViewQueue.next(controller: viewController)
    }
    
    // These two methods are part of what is needed for the PageControl
    //func presentationCount(for pageViewController: UIPageViewController) -> Int {
    //    return 7
    //}

    //func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    //    return 1
    //}
 
    //
    // Delegate
    //
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        //let page = pendingViewControllers[0] as! ReaderViewController
        //print("will Transition To \(page.reference.toString())")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        let page = self.pageViewController.viewControllers![0] as! ReaderViewController
        print("Display \(page.reference.toString())")
        self.toolBar.loadBiblePage(reference: page.reference)
        HistoryModel.shared.changeReference(reference: page.reference)
    }
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}
