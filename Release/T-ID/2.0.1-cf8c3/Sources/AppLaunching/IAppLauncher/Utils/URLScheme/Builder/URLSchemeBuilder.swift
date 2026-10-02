//
//  URLSchemeBuilder.swift
//  T-ID
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

final class URLSchemeBuilder: IURLSchemeBuilder {

    enum Param: String {
        case clientId
        case codeChallenge
        case codeChallengeMethod
        case callbackUrl
        case sdkVersion
    }

    private let authDomains: [String]

    init(authDomains: [String]) {
        self.authDomains = authDomains
    }

    func buildUrlSchemes(with options: AppLaunchOptions) -> [URL] {
        var params = [
            Param.clientId: options.clientId,
            .codeChallenge: options.payload.challenge,
            .codeChallengeMethod: options.payload.challengeMethod,
            .callbackUrl: options.callbackUrl
        ]
        if let sdkVersion = options.sdkVersion {
            params[.sdkVersion] = sdkVersion
        }

        return authDomains.compactMap { authDomain in
            let partnerAuthLink = authDomain + .partnerAuthSuffix
            var components = URLComponents(string: partnerAuthLink)
            components?.queryItems = params.map {
                URLQueryItem(name: $0.key.rawValue, value: $0.value)
            }
            return components?.url
        }
    }
}

private extension String {
    static let partnerAuthSuffix = "partner_auth"
}
