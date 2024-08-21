//
//  AppDelegate.swift
//  Tabula
//
//  Created by Lucas Rott on 21.08.24.
//

import Foundation
import Cocoa
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var flagsMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let key: String = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true]
        let enabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        if !enabled {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission is not granted"
            alert.informativeText = "For this app to work it needs to have accessibility permission granted in Security & Privacy. You need to start the app again after you allowed the permission."
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .warning
            alert.runModal()
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            NSApp.terminate(nil)
        }
        
        var mouseMonitor: Any?
        var initialPos: CGPoint?
        var lastPos: CGPoint?
        var lastDelta: CGPoint?
        flagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
            if let mouseMonitor = mouseMonitor {
                NSEvent.removeMonitor(mouseMonitor)
            }
            mouseMonitor = nil
            
            let modifierAny = UserDefaults.standard
                .object(forKey: "modifier")
            let modifier = modifierAny != nil ? modifierAny as! String : "option"
            
            var flag: NSEvent.ModifierFlags
            switch modifier {
            case "control":
                flag = .control
            case "command":
                flag = .command
            case "shift":
                flag = .shift
            case "function":
                flag = .function
            default:
                flag = .option
            }
            
            if event.modifierFlags.contains(flag) {
                let scrollSpeedAny = UserDefaults.standard
                    .object(forKey: "scrollSpeed")
                let scrollSpeed = scrollSpeedAny != nil ? scrollSpeedAny as! CGFloat : 20.0
                
                let xEnabledAny = UserDefaults.standard.object(forKey: "xEnabled")
                let xEnabled = xEnabledAny != nil ? xEnabledAny as! Bool : true
                let yEnabledAny = UserDefaults.standard.object(forKey: "yEnabled")
                let yEnabled = yEnabledAny != nil ? yEnabledAny as! Bool : true
                
                initialPos = CGEvent(source: nil)!.location
                mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { _ in
                    let pos = CGEvent(source: nil)!.location
                    if let lastPos = lastPos {
                        let delta = CGPoint(x: lastPos.x - pos.x, y: lastPos.y - pos.y)
                        if delta == CGPoint() {
                            return
                        }
                        var scroll = true
                        if let lastDelta = lastDelta {
                            if delta == CGPoint(x:-lastDelta.x,y:-lastDelta.y) {
                                scroll = false
                            }
                        }
                        if scroll {
                            var x: Int32 = 0
                            var y: Int32 = 0
                            
                            if xEnabled {
                                x = Int32(-delta.x * scrollSpeed)
                            }
                            if yEnabled {
                                y = Int32(-delta.y * scrollSpeed)
                            }
                            
                            let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: y, wheel2: x, wheel3: 0)
                            scrollEvent?.post(tap: CGEventTapLocation.cghidEventTap)
                        }
                        lastDelta=delta
                    }
                    lastPos = pos
                }
            } else {
                if initialPos != nil && lastPos != nil {
                    let mouseEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: initialPos!, mouseButton: CGMouseButton.left)
                    mouseEvent?.post(tap: CGEventTapLocation.cghidEventTap)
                }
                initialPos = nil
                lastPos = nil
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let flagsMonitor = flagsMonitor {
            NSEvent.removeMonitor(flagsMonitor)
        }
    }
}
