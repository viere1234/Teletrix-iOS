//
//  Session+Keychain.swift
//  Teletrix
//
//  Created by Brian Chang on 2023/7/1.
//

import MatrixRustSDK
import KeychainAccess

extension Session {
    public func save(to keychain: Keychain) {
        keychain["homeserver"] = self.homeserverUrl
        keychain["userId"] = self.userId
        keychain["accessToken"] = self.accessToken
        keychain["deviceId"] = self.deviceId
    }
    
    public static func from(_ keychain: Keychain) -> Session? {
        guard
            let homeserver = keychain["homeserver"],
            let userId = keychain["userId"],
            let accessToken = keychain["accessToken"],
            let deviceId = keychain["deviceId"]
        else {
            return nil
        }
        
        return Session(accessToken: accessToken, refreshToken: nil, userId: userId, deviceId: deviceId, homeserverUrl: homeserver, slidingSyncProxy: nil)
    }
}
