//
//  ContentView.swift
//  Teletrix
//
//  Created by Brian Chang on 2023/6/30.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var teletrix: TeletrixService
    
    var body: some View {
        switch teletrix.loginState {
        case .loggedIn(userId: let userId):
            EmptyView()
            
        case .loggedOut:
            LoginView()
            
        case .authenticating:
            EmptyView()
            
        case .failure(let error):
            EmptyView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
