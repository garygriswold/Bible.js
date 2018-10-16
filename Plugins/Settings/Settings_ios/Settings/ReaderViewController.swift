//
//  ReaderViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import WebKit

class ReaderViewController: UIViewController, WKUIDelegate {
    
    private var webView: WKWebView!
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func loadView() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.uiDelegate = self // Not used
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle: Bundle = Bundle.main
        let path = bundle.path(forResource: "www/index", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Did Receive Memory Warning called")
        // Dispose of any resources that can be recreated.
    }
}



