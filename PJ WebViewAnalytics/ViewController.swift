//
//  ViewController.swift
//  PJ WebViewAnalytics
//
//  Created by Bisma S Wasesasegara on 5/10/19.
//  Copyright © 2019 Bisma S Wasesasegara. All rights reserved.
//

import UIKit
import WebKit
import Firebase

class ViewController: UIViewController {

    private var webView: WKWebView!
    private var projectURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the hosted site url from the GoogleService-Info.plist file.
//        let plistPath = Bundle.main.path(forResource: "GoogleService-Info",
//                                         ofType: "plist")!
//        let plist = NSDictionary(contentsOfFile: plistPath)!
//        let appID = plist["PROJECT_ID"] as! String
        
        let projectURLString = "https://www.google.com"
        self.projectURL = URL(string: projectURLString)!
        
        // Initialize the webview and add self as a script message handler.
        let userScript = WKUserScript(source: webViewJavaScriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // MARK: Add handler
        webView.configuration.userContentController.add(self, name: "Firebase")
        
        view.addSubview(webView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        webView.evaluateJavaScript(webViewJavaScriptSource) { (result, error) in
            if let error = error {
                print(error)
            }
            if let result = result {
                print(result)
            }
        }
        
        let request = URLRequest(url: projectURL)
        webView.load(request)
    }
}

extension ViewController: WKScriptMessageHandler {
    // MARK: - Handle Message
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        guard let command = body["command"] as? String else { return }
        guard let name = body["name"] as? String else { return }
        
        if command == "setUserProperty" {
            guard let value = body["value"] as? String else { return }
            Analytics.setUserProperty(value, forName: name)
        } else if command == "logEvent" {
            guard let params = body["parameters"] as? [String: NSObject] else { return }
            Analytics.logEvent(name, parameters: params)
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            print("Opening webpage: \(navigationAction.request)")
            webView.load(navigationAction.request)
        case .reload:
            print("Reload webpage.")
        case .formResubmitted:
            print("Resubmit form.")
        case .formSubmitted:
            print("Form submitted.")
        default:
            break
        }
        decisionHandler(.allow)
    }
}

extension ViewController: WKUIDelegate {
    // Handle Alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true)
    }
}
