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
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let enabled = AXIsProcessTrustedWithOptions(options)
        if !enabled {
            CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: 0, wheel2: 0, wheel3: 0)?.post(tap: CGEventTapLocation.cghidEventTap)
            UserDefaults.standard.setValue(true, forKey: "needsPermission")
            return
        } else {
            UserDefaults.standard.setValue(false, forKey: "needsPermission")
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
            
            if event.modifierFlags.contains(self.getModifierFlag()) {
                let scrollSpeedAny = UserDefaults.standard
                    .object(forKey: "scrollSpeed")
                let scrollSpeed = scrollSpeedAny != nil ? scrollSpeedAny as! CGFloat : 20.0
                
                let naturalScrollingAny = UserDefaults.standard.object(forKey: "naturalScrolling")
                let naturalScrolling = naturalScrollingAny != nil ? naturalScrollingAny as! Bool : true
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
                                x = Int32(delta.x * scrollSpeed)
                            }
                            if yEnabled {
                                y = Int32(delta.y * scrollSpeed)
                            }
                            
                            if naturalScrolling {
                                x = -x
                                y = -y
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
    
    func getModifierFlag() -> NSEvent.ModifierFlags {
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
        
        return flag
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let flagsMonitor = flagsMonitor {
            NSEvent.removeMonitor(flagsMonitor)
        }
    }
}
