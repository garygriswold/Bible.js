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
    let userContentController = WKUserContentController()
    
    override func loadView() {
        AwsS3.region = "us-west-2"
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = self.userContentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var css: String = ""
        do {
            let cssUrl: URL? = Bundle.main.url(forResource: "Codex", withExtension: "css")
            if let cssUrl2 = cssUrl {
                css = try String(contentsOf: cssUrl2, encoding: .utf8)
            }
        }
        catch let err {
            print("Error reading css file \(err)")
        }

        let script = "alert('Hello World from JS');"
        //let script = "body.innerHtml = \"Hello World from JS\";"
        let userScript = WKUserScript(source: script,
                                      injectionTime: WKUserScriptInjectionTime.atDocumentStart,
                                      forMainFrameOnly: true)
        self.userContentController.addUserScript(userScript)
        
        AwsS3.shared.preSignedUrlGET(s3Bucket: "text-" + AwsS3.region + "-shortsands",
                                     s3Key: "ENGKJVT_04_JHN_003.html",
                                     expires: 3600,
                                     complete: { url in
            print("URL is \(String(describing:url))")
            if let goodUrl = url {
                //let request = URLRequest(url: goodUrl)
                //self.webView.load(request)

                var html: String = ""
                let task = URLSession.shared.dataTask(with: goodUrl) {
                    (data, response, error) in
                    html = String(data: data!, encoding: String.Encoding.utf8) ?? ""
                    let page = "<html><head><style>" + css + "</style></head><body>" + html + "</body></html>"
                    self.loadPageOnMainThread(page: page)
                }
                task.resume()
            }
        })
    }
    
    private func loadPageOnMainThread(page: String) {
        DispatchQueue.main.async {
            self.webView.loadHTMLString(page, baseURL: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// let script = "var rootNode = document.createElement('div');\n" +
//rootNode.setAttribute('id', 'top' + this.nodeId);
//"rootNode.innerHTML = html;\n" +
// "body.appendChild(rootNode);\n"

