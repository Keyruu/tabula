//
//  PermissionsService.swift
//  Tabula
//
//  Created by Lucas Rott on 07.09.24.
//

import Cocoa
import SwiftUI

// Thanks to https://github.com/othyn/macos-auto-clicker/blob/main/auto-clicker/Services/PermissionsService.swift
// This is a big pain.

final class PermissionsService: ObservableObject {
    static var shared: PermissionsService = .init()
    private init() {}

    func pollAccessibilityPrivileges(onTrusted: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let isTrusted = AXIsProcessTrusted()
            UserDefaults.standard.setValue(!isTrusted, forKey: "needsPermission")

            if !isTrusted {
                self.pollAccessibilityPrivileges(onTrusted: onTrusted)
            } else {
                onTrusted()
            }
        }
    }

    static func acquireAccessibilityPrivileges() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let enabled = AXIsProcessTrustedWithOptions(options)
        
        print(enabled)
    }
}
