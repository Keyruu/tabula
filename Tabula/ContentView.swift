//
//  ContentView.swift
//  Tabula
//
//  Created by Lucas Rott on 21.08.24.
//

import AppKit
import SwiftUI
import LaunchAtLogin

struct ContentView: View {
    // Define a property using @AppStorage
    @AppStorage("modifier") private var modifier = "option"
    @AppStorage("scrollSpeed") private var scrollSpeed = 20.0
    @AppStorage("naturalScrolling") private var naturalScrolling = true
    @AppStorage("xEnabled") private var xEnabled = true
    @AppStorage("yEnabled") private var yEnabled = true
    @AppStorage("needsPermission") private var needsPermission = false
    
    var body: some View {
        VStack {
            if needsPermission {
                Text("This app needs accessbility access! Please restart the app after you've given the permission.")
            } else {
                Form {
                    LabeledContent("General:") {
                        LaunchAtLogin.Toggle()
                    }
                    Picker("Modifier:", selection: $modifier) {
                        Text("Option \(Image(systemName: "option"))").tag("option")
                        Text("Control \(Image(systemName: "control"))").tag("control")
                        Text("Command \(Image(systemName: "command"))").tag("command")
                        Text("Shift \(Image(systemName: "shift"))").tag("shift")
                        Text("Function \(Image(systemName: "globe"))").tag("function")
                    }
                    LabeledContent("Scroll Direction:") {
                        Toggle("Natural Scrolling", isOn: $naturalScrolling)
                    }
                    HStack {
                        Toggle("X", isOn: $xEnabled)
                        Toggle("Y", isOn: $yEnabled)
                    }
                    VStack {
                        Slider(value: $scrollSpeed, in: 1...100) {
                            Text("Scroll Speed:")
                        } minimumValueLabel: {
                            Text("1")
                        } maximumValueLabel: {
                            Text("100")
                        }
                    }
                    Text("\(scrollSpeed, specifier: "%.0f")")
                }.multilineTextAlignment(.leading)
            }
            Divider()
            Button("Quit", action: { NSApplication.shared.terminate(nil) })
        }.padding(10)
    }
}
