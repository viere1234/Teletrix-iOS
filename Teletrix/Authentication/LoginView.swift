//
//  LoginView.swift
//  Teletrix
//
//  Created by Brian Chang on 2023/6/30.
//

import SwiftUI

struct LoginView: View {
    enum Field: Hashable {
        case server
        case username
        case password
    }
    
    @EnvironmentObject private var store: AccountStore
    
    @State private var username = ""
    @State private var password = ""
    @State private var server = "matrix.org"
    
    @State private var showingRegisterView = false
    @FocusState private var focused: Field?
    
    var body: some View {
        VStack() {
            Text("Welcome")
                .font(.title)
                .fontWeight(.medium)
                .padding(.bottom, 5)
            
            serverField
            
            Divider()
            
            accountField
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .sheet(isPresented: $showingRegisterView) {
            SafariView(url: URL(string: "https://app.element.io/#/register")!)
        }
    }
    
    var serverField: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Where your conversations live")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            
            TextField("matrix.org", text: $server)
                .focused($focused, equals: .server)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            (focused == .server ? .yellow : Color(red: 209/255, green: 209/255, blue: 213/255)),
                            lineWidth: (focused == .server ? 2 : 1)))
        }
    }
    
    var accountField: some View {
        VStack(spacing: 10) {
            TextField("Username", text: $username)
                .focused($focused, equals: .username)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            (focused == .username ? .yellow : Color(red: 209/255, green: 209/255, blue: 213/255)),
                            lineWidth: (focused == .username ? 2 : 1)))
            
            SecureField("Password", text: $password)
                .focused($focused, equals: .password)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            (focused == .password ? .yellow : Color(red: 209/255, green: 209/255, blue: 213/255)),
                            lineWidth: (focused == .password ? 2 : 1)))
            
            Button { self.store.login(username: username, password: password, homeserver: server) } label: {
                HStack {
                    Spacer()
                    Text("Login")
                        .padding(.vertical, 10)
                        .foregroundColor(Color.white)
                        .bold()
                    Spacer()
                }.background(.blue).cornerRadius(5)
            }
            
            Button {
                self.showingRegisterView.toggle()
            } label: {
                Text("Register")
            }

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
