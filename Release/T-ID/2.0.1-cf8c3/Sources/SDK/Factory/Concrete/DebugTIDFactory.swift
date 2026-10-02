//
//  DebugTIDFactory.swift
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
import UIKit

/// Конфигурцаия для  `DebugTIDFactory`
public struct DebugConfiguration {
    let canRefreshTokens: Bool
    let canLogout: Bool

    /// Создаёт новый экземпляр конфигурцаия
    ///
    /// - Parameters:
    ///   - canRefreshTokens: Успешность обновления токена
    ///   - canLogout: Возможность разлогирования
    public init(canRefreshTokens: Bool, canLogout: Bool) {
        self.canRefreshTokens = canRefreshTokens
        self.canLogout = canLogout
    }
}

public final class DebugTIDFactory: ITIDFactory {

    private let callbackUrl: String
    private let configuration: DebugConfiguration

    public init(callbackUrl: String, configuration: DebugConfiguration) {
        self.callbackUrl = callbackUrl
        self.configuration = configuration
    }

    public func build() -> ITID {
        let router = UIApplication.shared
        let appLauncher = DebugAppLauncher(urlScheme: "tiddebug://?callbackUrl=\(callbackUrl)", router: router)

        return DebugTID(
            appLauncher: appLauncher,
            canRefreshTokens: configuration.canRefreshTokens,
            canLogout: configuration.canLogout
        )
    }
}
