//
//  AuthWebSession.swift
//  T-ID
//
//  Copyright (c) 2026 TBank
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

import AuthenticationServices
import UIKit

final class AuthWebSession: NSObject {

    // Dependencies
    private let options: AppLaunchOptions
    private var baseUrl: String

    // State
    private var parentVC: UIViewController?
    private var authSession: ASWebAuthenticationSession?

    init(
        options: AppLaunchOptions,
        baseUrl: String
    ) {
        self.options = options
        self.baseUrl = baseUrl
    }
}

extension AuthWebSession: IAuthWebSession {

    func start(
        from parent: UIViewController?,
        completion: @escaping (Result<URL, TAuthError>) -> Void
    ) {
        let authURL: URL
        do {
            authURL = try buildWebViewURL()
        } catch {
            completion(.failure(.invalidWebSessionAuthURL))
            return
        }

        let sessionCompletion: (URL?, Error?) -> Void = { [weak self] url, error in
            guard let self else { return }
            defer {
                self.authSession = nil
                self.parentVC = nil
            }

            if let error {
                if let sessionError = error as? ASWebAuthenticationSessionError {
                    switch sessionError.code {
                    case .canceledLogin:
                        completion(.failure(.cancelledByUser))
                    case .presentationContextInvalid:
                        completion(.failure(.invalidPresentationContext))
                    case .presentationContextNotProvided:
                        completion(.failure(.failedToLaunchWebSession))
                    @unknown default:
                        completion(.failure(.authWebSessionFailed(AnyEquatableError(sessionError))))
                    }
                } else {
                    completion(.failure(.authWebSessionFailed(AnyEquatableError(error))))
                }
                return
            }

            guard let url else {
                completion(.failure(.missingAuthCodeURL))
                return
            }
            completion(.success(url))
        }

        let session: ASWebAuthenticationSession
        if #available(iOS 17.4, *) {
            do {
                session = try ASWebAuthenticationSession(
                    url: authURL,
                    callback: buildSessionCallback(),
                    completionHandler: sessionCompletion
                )
            } catch {
                completion(.failure(.invalidWebSessionCallbackURL))
                return
            }
        } else {
            guard let callbackURLScheme = buildCallbackURLScheme(),
                  callbackURLScheme != "https" else {
                completion(.failure(.invalidWebSessionCallbackURL))
                return
            }

            session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackURLScheme,
                completionHandler: sessionCompletion
            )
        }

        parentVC = parent

        session.presentationContextProvider = self

        guard session.start() else {
            completion(.failure(.failedToLaunchWebSession))
            return
        }

        authSession = session
    }

    func cancel() {
        authSession?.cancel()
        authSession = nil
        parentVC = nil
    }

    private func buildWebViewURL() throws -> URL {
        var params = [
            "client_id": options.clientId,
            "code_verifier": options.payload.verifier,
            "code_challenge_method": options.payload.challengeMethod,
            "code_challenge": options.payload.challenge,
            "redirect_uri": options.callbackUrl,
            "response_type": "code",
            "response_mode": "query"
        ]

        if let phone = options.phone {
            params["phone"] = phone
        }

        var components = URLComponents(string: "\(baseUrl)/auth/authorize")
        let redirectUriAllowedChars: CharacterSet = .alphanumerics.union(.init(charactersIn: "-._~"))

        components?.percentEncodedQueryItems = params.map { key, value in
            if key == "redirect_uri" {
                return URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: redirectUriAllowedChars))
            } else {
                return URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            }
        }

        enum Error: Swift.Error {
            case unableToInitializeUrl
        }

        guard let url = components?.url else {
            throw Error.unableToInitializeUrl
        }

        return url
    }

    @available(iOS 17.4, *)
    private func buildSessionCallback() throws -> ASWebAuthenticationSession.Callback {
        enum Error: Swift.Error {
            case unableToInitializeCallback
        }

        guard let components = URLComponents(string: options.callbackUrl),
              let scheme = components.scheme else {
            throw Error.unableToInitializeCallback
        }

        if scheme == "https" {
            guard let host = components.host else {
                throw Error.unableToInitializeCallback
            }

            return .https(host: host, path: components.path)
        }
        return .customScheme(scheme)
    }

    private func buildCallbackURLScheme() -> String? {
        URLComponents(string: options.callbackUrl)?.scheme
    }
}

extension AuthWebSession: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return parentVC?.view.window ?? ASPresentationAnchor()
    }
}
