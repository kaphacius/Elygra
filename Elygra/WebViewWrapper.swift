//
//  WebViewWrapper.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 08/12/2020.
//

import SwiftUI
import WebKit

final class WebViewWrapper: NSObject, UIViewRepresentable {
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(
        _ webView: WKWebView,
        context: UIViewRepresentableContext<WebViewWrapper>
    ) {
        _ = url
            .map { URLRequest(url: $0) }
            .map(webView.load)
    }
}
