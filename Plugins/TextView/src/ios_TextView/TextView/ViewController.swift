//
//  ViewController.swift
//  TextView
//
//  Created by Gary Griswold on 10/14/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
import UIKit
import WebKit
import AWS

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        AwsS3.region = "us-west-2"
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AwsS3.shared.preSignedUrlGET(s3Bucket: "text-" + AwsS3.region + "-shortsands",
                                     s3Key: "ENGKJVT_04_JHN_003.html",
                                     expires: 3600,
                                     complete: { url in
            print("URL is \(String(describing:url))")
            if let goodUrl = url {
                let request = URLRequest(url: goodUrl)
                self.webView.load(request)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

