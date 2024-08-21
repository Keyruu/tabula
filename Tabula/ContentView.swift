//
//  ContentView.swift
//  Tabula
//
//  Created by Lucas Rott on 21.08.24.
//

import AppKit
import SwiftUI

struct ContentView: View {
    // Define a property using @AppStorage
    @AppStorage("modifier") private var modifier = "option"
    @AppStorage("scrollSpeed") private var scrollSpeed = 20.0
    @AppStorage("xEnabled") private var xEnabled = true
    @AppStorage("yEnabled") private var yEnabled = true
    
    var body: some View {
        VStack {
            Form {
                Picker("Modifier", selection: $modifier) {
                    Text("Option \(Image(systemName: "option"))").tag("option")
                    Text("Control \(Image(systemName: "control"))").tag("control")
                    Text("Command \(Image(systemName: "command"))").tag("command")
                    Text("Shift \(Image(systemName: "shift"))").tag("shift")
                    Text("Function \(Image(systemName: "globe"))").tag("function")
                }
                LabeledContent("Scroll Direction") {
                    Toggle("X", isOn: $xEnabled)
                    Toggle("Y", isOn: $yEnabled).padding(.leading, 10)
                }
                Slider(value: $scrollSpeed, in: 5...200, step: 5) {
                    Text("Scroll Speed")
                } minimumValueLabel: {
                    Text("5")
                } maximumValueLabel: {
                    Text("200")
                }
                Text("\(scrollSpeed, specifier: "%.0f")").frame(width: 200).multilineTextAlignment(.center)
            }
            Divider()
            Button("Quit", action: { NSApplication.shared.terminate(nil) })
        }.padding(10)
    }
}
