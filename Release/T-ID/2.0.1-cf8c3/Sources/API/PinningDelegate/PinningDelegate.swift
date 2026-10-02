//
//  PinningDelegate.swift
//  Pods-TIDExample
//
//  Copyright (c) 2024 TBank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import TCSSSLPinningPublic
import WebKit

protocol IPinningDelegate {}

final class PinningDelegate: NSObject, IPinningDelegate {

    // MARK: - Dependencies

    private var httpPublicKeyPinningService: IHTTPPublicKeyPinningService

    // MARK: - Lifestyle

    init(hostAndPinsURL: String?) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let bundleID = Bundle.main.bundleIdentifier?.description ?? "ru.tbank.id"
        let configuration = HPKPServiceConfiguration(
            hostAndPinsURL: hostAndPinsURL.flatMap(URL.init(string:)) ?? .defaultHostAndPins,
            untrustedConnectionPolicy: .continue,
            cachedHostsAndPinsDefaultsKey: "\(bundleID).hostsandpins",
            appParameters: AppParameters(version: version ?? "1.0", origin: "origin")
        )
        self.httpPublicKeyPinningService = HPKPServiceAssembly.createHPKPPinningService(with: configuration)

        httpPublicKeyPinningService.configure()
        httpPublicKeyPinningService.updateHostsAndPins()

        super.init()
    }
}

// MARK: - URLSessionDelegate

extension PinningDelegate: URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        httpPublicKeyPinningService.urlSession?(session, didBecomeInvalidWithError: error)
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        httpPublicKeyPinningService.urlSession?(
            session,
            didReceive: challenge,
            completionHandler: completionHandler
        )
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        httpPublicKeyPinningService.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
    }
}

// MARK: - WKNavigationDelegate

extension PinningDelegate: WKNavigationDelegate {
    public func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        httpPublicKeyPinningService.webView?(webView, didReceive: challenge, completionHandler: completionHandler)
    }
}
