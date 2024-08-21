//
//  TabulaApp.swift
//  Tabula
//
//  Created by Lucas Rott on 20.08.24.
//

import SwiftUI

@main
struct TabulaApp: App {
    @AppStorage("accessibilityDenied") private var accessiblity = false
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("TabulaApp", image: "Icon") {
            ContentView()
        }.menuBarExtraStyle(.window)

    }
}
