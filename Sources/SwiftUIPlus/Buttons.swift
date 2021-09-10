//
//  Buttons.swift
//  Buttons
//
//  Created by Orijhins on 09/09/2021.
//

import Foundation
import SwiftUI

/**
 A Button that displays an Icon and Text if necessary.
 On macOS 10.15, use NSImage.Name instead of SFSymbols, as it isn't supported by the System.
 */
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PlusIconButton: View {
    let action: (() -> Void)
    let label: String
    let icon: String
    
    @available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
    public init(label: String, icon: String, action: @escaping (() -> Void)) {
        self.label = label
        self.icon = icon
        self.action = action
    }
    public init(icon: String, action: @escaping (() -> Void)) {
        self.label = ""
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            #if os(iOS)
            Label(label, image: icon)
            #else
            if #available(macOS 11.0, *) {
                Label(label, systemImage: icon)
            } else {
                // Fallback on earlier versions
                Image(nsImage: NSImage(named: icon) ?? NSImage())
            }
            #endif
        }
    }
}
