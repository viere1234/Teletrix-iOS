//
//  MatrixService.swift
//  Teletrix
//
//  Created by Brian Chang on 2023/6/30.
//

import Foundation
import MatrixRustSDK
import KeychainAccess

public class TeletrixService: ObservableObject, ClientDelegate {
    public var client: Client?
    
    private var session: Session?
    
    private let keychain = Keychain(service: "com.brianchang.teletrix")
    
    public init() {
        if let session = Session.from(keychain) {
            self.loginState = .authenticating
            self.session = session
            do {
                let client = try ClientBuilder()
                    .basePath(path: URL.applicationSupportDirectory.path())
                    .homeserverUrl(url: session.homeserverUrl)
                    .build()
                try client.restoreSession(session: session)
                self.client = client
                self.loginState = .loggedIn(userId: session.userId)
            } catch {
                self.loginState = .failure(error)
            }
        }
    }
    
    // MARK: - Login
    @Published public var loginState: LoginState = .loggedOut
    private let authenticationService = AuthenticationService(basePath: URL.applicationSupportDirectory.path(), passphrase: nil, userAgent: nil, customSlidingSyncProxy: nil)
    
    public func configureHomeserver(server: String) async throws {
        try authenticationService.configureHomeserver(serverNameOrHomeserverUrl: server)
    }
    
    public func login(username: String, password: String) async {
        self.loginState = .authenticating
        
        do {
            self.client = try authenticationService.login(username: username, password: password, initialDeviceName: nil, deviceId: nil)
            self.session = try client?.session()
            session?.save(to: self.keychain)
        } catch {
            self.loginState = .failure(error)
        }
    }
    
    // MARK: - Sync
    private func sync() {
        client?.setDelegate(delegate: self)
    }
    
    // MARK: - Room
    @Published public var rooms = [Room]()
        
    public func didReceiveSyncUpdate() {
        // Update the user's room list on each sync response.
        self.rooms = self.client?.rooms() ?? []
    }
        
    public func didReceiveAuthError(isSoftLogout: Bool) {
        // Ask the user to reauthenticate.
    }
        
    public func didUpdateRestoreToken() {
        if let session = try? self.client?.session() {
            self.session = session
            self.session?.save(to: self.keychain)
        }
    }
}

public enum LoginState {
    case loggedOut
    case authenticating
    case failure(Error)
    case loggedIn(userId: String)
}
