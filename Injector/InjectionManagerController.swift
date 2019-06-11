//
//  ViewController.swift
//  Injector
//
//  Created by Trevor Behlman on 5/5/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import Cocoa
import WebKit

class InjectionManagerController: NSViewController, WKScriptMessageHandler {
    var webView: WKWebView?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body as! [String: Any]
        let action = body["action"] as! String
        do {
            switch action {
            case "create":
                try createInjection(body["injection"] as! [String: Any])
            case "retrieve":
                try retrieveInjections()
            case "update":
                try updateInjection(body["id"] as! String, withData: body["injection"] as! [String: Any])
            case "delete":
                try deleteInjection(body["id"] as! String)
            default:
                print("Received unknown action \"\(action)\" from manager")
            }
        } catch {
            print("Unable to process manager action \"\(action)\"")
        }
    }
    
    func retrieveInjections() throws {
        let injections = InjectionManager.getInjections().map { $0.toDictionary() }
        let json = String(data: try JSONSerialization.data(withJSONObject: injections, options: []), encoding: .utf8)!
        webView!.evaluateJavaScript("hasLoadedInjections(\(json))")
    }
    
    func createInjection(_ data: [String: Any]) throws {
        let injection = Injection(from: data)
        try InjectionManager.context.save()
        let json = String(data: try JSONSerialization.data(withJSONObject: injection.toDictionary(), options: []), encoding: .utf8)!
        webView!.evaluateJavaScript("injectionWasCreated(\(json))")
    }
    
    func updateInjection(_ id: String, withData data: [String: Any]) throws {
        let injection = try InjectionManager.getInjection(id)
        injection.update(from: data)
        try InjectionManager.context.save()
    }
    
    func deleteInjection(_ id: String) throws {
        let injection = try InjectionManager.getInjection(id)
        InjectionManager.context.delete(injection)
        try InjectionManager.context.save()
    }
    
    override func loadView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "injector")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 800, height: 500), configuration: config)
        view = webView!
        
        let managerURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "manager")!
        webView!.loadFileURL(managerURL, allowingReadAccessTo: managerURL)
    }
}
