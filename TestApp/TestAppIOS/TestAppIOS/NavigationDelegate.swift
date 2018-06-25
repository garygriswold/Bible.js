//
//  NavigationDelegate.swift
//  TestAppIOS
//
//  Created by Gary Griswold on 6/23/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import WebKit

class NavigationDelegate : NSObject, WKNavigationDelegate {
    
    /** Called when the web view begins to received web content */
    func webView(_ webView: WKWebView, didCommit: WKNavigation!) {
        print("**** WKNavigationDelegate began to receive web content ****")
    }
    
    /** Called when web content begins to load in a web view */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation: WKNavigation!) {
        print("**** WKNavigationDelegate didStartProvisionalNavigation ****")
    }
    
    /** Called when a web view receives a server redirect */
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation: WKNavigation!) {
        print("**** WKNavigationDelegate didReceiveServerRedirectForProvisionalNavigation ****")
    }
    
    /** Called when the web view needs to respond to an authentication challenge */
    func webView(_ webView: WKWebView, didReceive: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("**** WKNavigationDelegate did receive authentication challenge ****")
    }
    
    /** Called when an error occurs during navigation */
    func webView(_ webView: WKWebView, didFail: WKNavigation!, withError: Error) {
        print("**** WKNavigationDelegate Navigation Error \(withError) ****")
    }
    
    /** Called when an error occurs while the web view is loading content */
    func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
        print("**** WKNavigationDelegate Loading Error \(withError) ****")
    }
    
    /** Called when navigation is complete */
    func webView(_ webView: WKWebView, didFinish: WKNavigation!) {
        print("**** WKNavigationDelegate didFinish ****")
    }
    
    /** Called when the web view’s web content process is terminated */
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("**** WKNavigationDelegate contentProcessDidTerminate ****")
    }
    
    /** I left out permitting Navigation methods */
    
}
