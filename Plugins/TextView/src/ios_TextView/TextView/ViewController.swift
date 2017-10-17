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

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    
    override open var shouldAutorotate: Bool {
        return false
    }
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func loadView() {
        super.loadView()
 //       AwsS3.region = "us-west-2"
/*
        //let script = "alert('Hello World from JS');"
        let script = "document.body.innerHtml = 'Hello World from JS';"
        //let script = "document.body.style.background = '#ABCDEF';";
        let userScript = WKUserScript(source: script,
                                      injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                                      forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        //userContentController.add(self, name: "buttonClicked")
*/
        let config = WKWebViewConfiguration()
//        config.userContentController = userContentController

        config.dataDetectorTypes = []
        
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = webView
    }
    /**
     * Method required for WKScriptMessageHandler
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "buttonClicked") {
            print("Button has been clicked")
        }
        //if message.body instanceof Dictionary {
        //if message.body is Dictionary {
        //    let idOfTappedButton: String = message.body["ButtonId"]
        //    print("Clicked \(idOfTappedButton)")
        //}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let css: String = self.readBundle(name: "Codex", fileType: "css")
        let body: String = self.readBundle(name: "Codex", fileType: "html")
        let page = "<html><head><style>" + css + "</style></head>" + body + "</html>"
        self.loadPageOnMainThread(page: page)
/*
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
                    //let page = "<html><body><p>Hello World</p></body></html>"
                    self.loadPageOnMainThread(page: page)
                }
                task.resume()
            }
        })
 */
    }
    
    private func readBundle(name: String, fileType: String) -> String {
        var text: String = ""
        do {
            let bundleURL = Bundle.main.url(forResource: name, withExtension: fileType)
            if let url = bundleURL {
                text = try String(contentsOf: url, encoding: .utf8)
            }
        }
        catch let err {
            print("Error reading bundle file \(err)")
        }
        return text
    }
    
    private func loadPageOnMainThread(page: String) {
        DispatchQueue.main.async {
            self.webView.loadHTMLString(page, baseURL: nil)
            
//            self.webView.evaluateJavaScript("window.alert('Hi from JS');",
//                                            completionHandler: { result, err in
//                print("RESULT \(result)")
//                print("ERROR \(err)")
//            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /**
     * This func is provided by WKUIDelegate
     */
    func webViewDidClose(_ webView: WKWebView) {
        print("webView Did Close is called")
    }
    /**
     * These funcs are provided by WKNavigationDelegate
     */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("** Did start provisional navigation")
    }
//    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        print("** Did receive server redirect for provisional navigation")
//    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("** DidFail navigation with Error \(error)")
    }
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        print("** DidFail provisional nvaigation with Error \(error)")
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("** Did commit navigation")
    }
}

