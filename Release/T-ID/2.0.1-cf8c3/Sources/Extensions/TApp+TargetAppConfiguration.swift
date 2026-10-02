//
//  TApp+TargetAppConfiguration.swift
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

extension TApp: TargetAppConfiguration {

    public var urlScheme: String {
        switch self {
        case .bank:
            return "bank100000000004://"
        }
    }

    public var usesUniversalLinks: Bool {
        switch self {
        case .bank:
            return true
        }
    }

    public var authDomains: [String] {
        switch self {
        case .bank:
            return ["https://ipa.srv-hub.org/", "https://tinkoff.ru/"]
        }
    }
}
