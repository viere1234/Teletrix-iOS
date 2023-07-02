//
//  MatrixService.swift
//  Teletrix
//
//  Created by Brian Chang on 2023/6/30.
//

import Foundation
import MatrixSDK
import KeychainAccess

public class AccountStore: ObservableObject {
    public var session: MXSession?
    public var client: MXRestClient?
    
    private var fileStore: MXFileStore?
    private var credentials: MXCredentials?
    
    private let keychain = Keychain(service: "com.brianchang.teletrix")
    
    public init() {
        let sdkOption = MXSDKOptions.sharedInstance()
        sdkOption.enableCryptoWhenStartingMXSession = true
        sdkOption.computeE2ERoomSummaryTrust = true
        if let credentials = MXCredentials.from(keychain) {
            self.loginState = .authenticating
            self.credentials = credentials
            self.sync()
        }
    }
    
    // MARK: - Login
    @Published public var loginState: LoginState = .loggedOut
    
    public func login(username: String, password: String, homeserver: String) {
        self.loginState = .authenticating
        var homeserverURLComponents = URLComponents(string: (homeserver.contains("//") ? "" : "//") + homeserver)
        homeserverURLComponents?.scheme = "https"
        guard let homeserverURL = homeserverURLComponents?.url else { return }
        print("#::\(homeserverURL.absoluteString)")
        self.client = MXRestClient(homeServer: homeserverURL, unrecognizedCertificateHandler: nil)
        self.client?.login(type: .password, username: username, password: password) { response in
            switch response {
            case .failure(let error):
                self.loginState = .failure(error)
            case .success(let credentials):
                self.credentials = credentials
                self.credentials?.save(to: self.keychain)
                self.sync()
            }
        }
    }
    
    // MARK: - Sync
    private func sync() {
        guard let credentials = self.credentials else { return }
        self.client = MXRestClient(credentials: credentials)
        self.session = MXSession(matrixRestClient: self.client)
        self.fileStore = MXFileStore()
        self.session?.setStore(self.fileStore!) { response in
            switch response {
            case .failure(let error):
                self.loginState = .failure(error)
            case .success():
                self.session?.start{ response in
                    switch response {
                    case .failure(let error):
                        self.loginState = .failure(error)
                    case .success():
                        let userId = credentials.userId!
                        self.loginState = .loggedIn(userId: userId)
                        //self.session?.crypto.warnOnUnknowDevices = false //?
                    }
                }
            }
        }
    }
}

public enum LoginState {
    case loggedOut
    case authenticating
    case failure(Error)
    case loggedIn(userId: String)
}
