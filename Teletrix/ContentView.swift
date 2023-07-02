//
//  ContentView.swift
//  Teletrix
//
//  Created by Brian Chang on 2023/6/30.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AccountStore
    
    var body: some View {
        switch store.loginState {
        case .loggedIn(userId: let userId):
            Text(userId)
            
        case .loggedOut:
            LoginView()
            
        case .authenticating:
            ProgressView()
            
        case .failure(let error):
            Text(error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
