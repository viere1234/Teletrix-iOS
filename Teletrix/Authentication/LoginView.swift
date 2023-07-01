//
//  LoginView.swift
//  Teletrix
//
//  Created by Brian Chang on 2023/6/30.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var teletrix: TeletrixService
    
    @State private var username = ""
    @State private var password = ""
    @State private var server = "matrix.org"
    
    @State private var showingEditServerView = false
    
    var body: some View {
        VStack() {
            Text("Welcome")
                .font(.title)
                .fontWeight(.medium)
                .padding(.bottom, 5)
            
            serverField
            
            Divider()
            
            
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .sheet(isPresented: $showingEditServerView) { EditServerView($server) }
    }
    
    var serverField: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Where your conversations live")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            
            HStack {
                Text(server)
                
                Spacer()
                
                Button { showingEditServerView.toggle() } label: {
                    Text("Edit")
                }

            }
        }
    }
}

struct EditServerView: View {
    
    @EnvironmentObject private var teletrix: TeletrixService
    @Environment(\.dismiss) private var dismiss
    @State private var editServer: String
    @State private var loading = false
    @Binding private var server: String
    @FocusState private var focused: Bool
    
    init(_ server: Binding<String>) {
        self._server = server
        self._editServer = State(wrappedValue: server.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "server.rack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.15)
                    .padding(.bottom)
                
                Text("Connect to homeserver")
                    .font(.title2)
                    .bold()
                
                Text("What is the address of your server?")
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                VStack {
                    TextField("matrix.org", text: $editServer)
                        .focused($focused, equals: true)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(
                                    (focused ? .yellow : Color(red: 209/255, green: 209/255, blue: 213/255)),
                                    lineWidth: (focused ? 2 : 1))
                                )
                    
                    Button {
                        self.loading = true
                        Task {
                            do {
                                try await teletrix.configureHomeserver(server: editServer)
                                self.server = self.editServer
                                self.dismiss()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        self.loading = false
                    } label: {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .padding(.vertical, 10)
                                .foregroundColor(Color.white)
                                .bold()
                            Spacer()
                        }.background(.blue).cornerRadius(5)
                    }

                }
                .frame(width: UIScreen.main.bounds.width * 0.9)
                
                Spacer()
                
                if loading {
                    ProgressView()
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
