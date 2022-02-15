//
//  DatePickers.swift
//  DatePickers
//
//  Created by Orijhins on 29/09/2021.
//

import Foundation
import SwiftUI

#if os(macOS)
@available(macOS 10.15, *)
public struct PlusDatePicker: NSViewRepresentable {
    public typealias NSViewType = NSDatePicker
    
    ///The Value held and displayed by the Picker
    @Binding public var value: Date?
    ///OPTIONAL: Set this to true if you want the Picker to be autofocused
    ///when the View is displayed or becomes active. Default is false
    public var autoFocus = false
    ///OPTIONAL: The Picker's Tag, used to navigate through PlusViews
    ///when Tab is pressed e.g. Default is 0
    public var tag: Int = 0
    ///The View's focusTag, which is shared between PlusViews. Update this
    ///one to navigate to a PlusView with the same tag
    @Binding public var focusTag: Int
    ///OPTIONAL: The Delegate Action to execute whenever the Value changes
    public var onChange: (() -> Void)?
    ///OPTIONAL: The Delegate Action to execute when the Tab Key is pressed
    public var onTabKeyStroke: (() -> Void)?
    ///OPTIONAL: The Delegate Action to execute when the BackTab Key is pressed
    public var onBackTabKeyStroke: (() -> Void)?
    
    @State fileprivate var didFocus = false
    
    public init(
        _ value: Binding<Date>,
        autoFocus: Bool = false, tag: Int = 0, focusTag: Binding<Int>,
        onChange: (() -> Void)? = nil,
        onTabKeyStroke: (() -> Void)? = nil, onBackTabKeyStroke: (() -> Void)? = nil
    ) {
        self._value = Binding(value)
        self.autoFocus = autoFocus
        self.tag = tag
        self._focusTag = focusTag
        self.onChange = onChange
        self.onTabKeyStroke = onTabKeyStroke
        self.onBackTabKeyStroke = onBackTabKeyStroke
    }
    
    public init(
        _ value: Binding<Date?>,
        autoFocus: Bool = false, tag: Int = 0, focusTag: Binding<Int>,
        onChange: (() -> Void)? = nil,
        onTabKeyStroke: (() -> Void)? = nil, onBackTabKeyStroke: (() -> Void)? = nil
    ) {
        self._value = value
        self.autoFocus = autoFocus
        self.tag = tag
        self._focusTag = focusTag
        self.onChange = onChange
        self.onTabKeyStroke = onTabKeyStroke
        self.onBackTabKeyStroke = onBackTabKeyStroke
    }
    
    public func makeNSView(context: Context) -> NSDatePicker {
        value = value != nil ? value : Date()
        let picker = NSDatePicker()
        picker.dateValue = value!
        picker.datePickerElements = .yearMonthDay
        picker.layer?.cornerRadius = 10
        picker.layer?.masksToBounds = true
        picker.delegate = context.coordinator
        picker.tag = tag
        picker.isBezeled = true
        picker.maxDate = Date()
        return picker
    }
    
    public func updateNSView(_ nsView: NSDatePicker, context: Context) {
        if autoFocus && !didFocus {
            NSApplication.shared.mainWindow?.perform(
                #selector(NSApplication.shared.mainWindow?.makeFirstResponder(_:)),
                with: nsView,
                afterDelay: 0.0
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(1)) {
                didFocus = true
            }
        }

        if focusTag == nsView.tag {
            NSApplication.shared.mainWindow?.perform(
                #selector(NSApplication.shared.mainWindow?.makeFirstResponder(_:)),
                with: nsView,
                afterDelay: 0.0)

            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(1)) {
                self.focusTag = 0
            }
        }
        guard value != nil, nsView.dateValue != value else {
            return
        }
        nsView.dateValue = value!
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    // MARK: Coordinator
    
    public class Coordinator: NSObject, NSDatePickerCellDelegate {
        var parent: PlusDatePicker

        init(with parent: PlusDatePicker) {
            self.parent = parent
            super.init()

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAppDidBecomeActive(notification:)),
                name: NSApplication.didBecomeActiveNotification,
                object: nil)
        }

        @objc func handleAppDidBecomeActive(notification: Notification) {
            if parent.autoFocus && !parent.didFocus {
                DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(1)) {
                    self.parent.didFocus = false
                }
            }
        }

        // MARK: NSDatePickerCellDelegate
        
        public func datePickerCell(_ datePickerCell: NSDatePickerCell, validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>, timeInterval proposedTimeInterval: UnsafeMutablePointer<TimeInterval>?) {
            parent.value = proposedDateValue.pointee as Date
            parent.onChange?()
        }

        public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSStandardKeyBindingResponding.insertTab(_:)) {
                parent.onTabKeyStroke?()
                return true
            } else if commandSelector == #selector(NSStandardKeyBindingResponding.insertBacktab(_:)) {
                parent.onBackTabKeyStroke?()
                return true
            }
            return false
        }
    }
}
#endif
