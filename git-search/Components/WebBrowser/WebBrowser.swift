//
//  WebBrowser.swift
//  git-search
//
//  Created by Alex on 3/26/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import WebKit

final class WebBrowser: UIViewController {
    
    private struct Trigger {
        let path: String
        let callback: (URL) -> ()
    }
    
    var url: URL? {
        didSet {
            if isViewLoaded {
                loadUrl(url)
            }
        }
    }
    
    private var webView: WKWebView?
    private var triggers: [Trigger] = []
    private var doneAction: (() -> ())? {
        didSet {
            guard doneAction != nil else {
                navigationItem.rightBarButtonItem = nil
                return
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnAction))
        }
    }
    
    init(url: URL? = nil) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        DispatchQueue.main.async {
            self.loadUrl(self.url)
        }
    }
    
    func addTrigger(path: String, callback: @escaping (URL) -> ()) {
        let trigger = Trigger(path: path, callback: callback)
        triggers.append(trigger)
    }
    func addDoneAction(_ action: @escaping () -> ()) {
        doneAction = action
    }

    func clearCache() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeCookies, WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeWebSQLDatabases, WKWebsiteDataTypeIndexedDBDatabases])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
    }
    
}

extension WebBrowser: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        for trigger in triggers {
            if let url = navigationAction.request.url, url.absoluteString.hasPrefix(trigger.path) {
                trigger.callback(url)
            }
        }
        decisionHandler(.allow)
    }
    
}

private extension WebBrowser {

    @objc func doneBtnAction() {
        doneAction?()
    }
    
    func setupView() {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.navigationDelegate = self
        self.webView = webView
    }
    
    func loadUrl(_ url: URL?) {
        if let url = url {
            webView?.load(URLRequest(url: url))
        } else if let url = URL(string: "about:blank") {
            webView?.load(URLRequest(url: url))
        }
    }
    
}
