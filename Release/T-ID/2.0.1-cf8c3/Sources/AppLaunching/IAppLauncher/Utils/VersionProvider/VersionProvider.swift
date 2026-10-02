//
//  VersionProvider.swift
//  T-ID
//
//  Created by Yaroslav Kosarev on 27.08.25.
//

import Foundation

protocol IVersionProvider {
    var componentVersion: String? { get }
}

extension Bundle: IVersionProvider {

    var componentVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    static var defaultBundle: Bundle {
        Bundle(for: BundleToken.self)
    }
}

private class BundleToken {}
