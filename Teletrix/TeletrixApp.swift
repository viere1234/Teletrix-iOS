//
//  TeletrixApp.swift
//  Teletrix
//
//  Created by Brian Chang on 2023/6/30.
//

import SwiftUI

@main
struct TeletrixApp: App {
    @StateObject private var teletrix = TeletrixService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(teletrix)
        }
    }
}
