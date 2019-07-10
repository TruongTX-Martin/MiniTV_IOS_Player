//
//  MSPlayer+Webview.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import Foundation
import WebKit

extension MSPlayer : WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler{
    
    func initWebview() {
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "jsToNative")
        
        let userScript = WKUserScript(source: "initNative()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        
        self.containerView.isOpaque = false
        self.containerView.backgroundColor = UIColor.clear
        
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.containerView.frame.size.height))
        self.webView = WKWebView (frame: customFrame , configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(webView)
        webView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.scrollView.bounces = false

        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    func openUrl() {
        let localFile = Bundle.main.path(forResource: "page", ofType: "html")
        let url = URL(fileURLWithPath: localFile!)
        let request = URLRequest(url: url)
        
//        let url = URL(string: "http://169.254.143.6:8080/?role=p")
//        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        self.viewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.viewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        self.viewController?.present(alertController, animated: true, completion: nil)
    }

    func callJS(jsFunctionName: String, data: String) {
        webView.evaluateJavaScript("\(jsFunctionName)('\(data)')", completionHandler: {(result, error) in
            if let result = result {
                print(result)
            }
        })
    }
    
    //Called from JS
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if message.name == "jsToNative" {

            if let dictionary: [String: String] = message.body as? Dictionary {

                if let function = dictionary["function"] {

                    print(function)
                    let json: Any? = dictionary["data"]
                    if let json = json {
                        print(json)
                    }

                    switch function {
                        
                    case "startWebRTC" :
                        if let parameters: [String: String] = json as? Dictionary {
                            let constraints : AVConstraint = self.jsonTo(json: parameters["constraints"], defValue: AVConstraint())
                            let iceConfiguration : ICEConfiguration = self.jsonTo(json: parameters["iceConfiguration"], defValue: ICEConfiguration())
                            self.startWebRTC(constraints: constraints, iceConfiguration: iceConfiguration)
                        }
                        
                    case "stopWebRTC" :
                        self.stopWebRTC()

                    case "createLocalVideo" :
                        let frame: Frame = self.jsonTo(json: json as? String, defValue: Frame())
                        self.createLocalVideo(frame)
                        
                    case "destroyLocalVideo" :
                        self.destroyLocalVideo()
                        
                    case "createRemoteVideo" :
                        let frame: Frame = self.jsonTo(json: json as? String, defValue: Frame())
                        self.createRemoteVideo(frame)
                        
                    case "destroyRemoteVideo" :
                        self.destroyRemoteVideo()
                        
                    case "onReceiveOffer" :
                        let sdp: SDP = self.jsonTo(json: json as? String, defValue: SDP())
                        self.onReceiveOffer(sdp)
                        
                    case "onReceiveAnswer" :
                        let sdp: SDP = self.jsonTo(json: json as? String, defValue: SDP())
                        self.onReceiveAnswer(sdp)
                        
                    case "onReceiveIceCandidate" :
                        let candidate: Candidate = self.jsonTo(json: json as? String, defValue: Candidate())
                        self.onReceiveIceCandidate(candidate)
                        

                    default:
                        printError("\(function) is not defined in ios native")
                    }
                }
            }
        }
    }
    
    func jsonTo<T: Codable>(json: String?, defValue: T) -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: json!.data(using: .utf8)!)
        } catch let parsingError {
            printError("Parsing error: \(parsingError)")
        }
        return defValue
    }
    
    func printError(_ message : String) {
        print(message)
        self.callJS(jsFunctionName: "console.log", data: "\(message)")
    }
}
