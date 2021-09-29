//
//  TextFields.swift
//  TextFields
//
//  Created by Orijhins on 09/09/2021.
//

import Foundation
import SwiftUI

// MARK: PlusTextField
#if os(macOS)
/**
 A TextField that accepts any Kind of Value and allows the User to cycle
 through the View with the Tab and BackTab Keys.
 */
@available(macOS 10.15, *)
public struct PlusTextField<Value>: NSViewRepresentable where Value: Hashable {
    public typealias NSViewType = NSTextField

    ///The Value hold and displayed by the TextField
    @Binding public var value: Value?
    ///OPTIONAL: The Formatter used by the TextField if necessary.
    ///Highly recommended if using non-StringProtocol Value
    public var formatter: Formatter?
    ///The Placeholder to display if the Value is empty
    public var placeholder: String
    ///OPTIONAL: Set this to true if you want the TextField to be autofocused
    ///when the View is displayed or becomes active. Default is false
    public var autoFocus = false
    ///OPTIONAL: The TextField's Tag, used to navigate through TextFields
    ///when Tab is pressed e.g. Default is 0
    public var tag: Int = 0
    ///The View's focusTag, which is shared between TextFields. Update this
    ///one to navigate to a TextField with the same tag
    @Binding public var focusTag: Int
    ///OPTIONAL: The Delegate Action to execute whenever the Value changes
    public var onChange: (() -> Void)?
    ///OPTIONAL: The Delegate Action to execute when Editing ends
    public var onCommit: (() -> Void)?
    ///OPTIONAL: The Delegate Action to execute when the Tab Key is pressed
    public var onTabKeyStroke: (() -> Void)?
    ///OPTIONAL: The Delegate Action to execute when the BackTab Key is pressed
    public var onBackTabKeyStroke: (() -> Void)?
    
    @State fileprivate var didFocus = false
    
    public init(
        _ value: Binding<Value?>,
        formatter: Formatter? = nil, placeholder: String,
        autoFocus: Bool = false, tag: Int = 0, focusTag: Binding<Int>,
        onChange: (() -> Void)? = nil, onCommit: (() -> Void)? = nil,
        onTabKeyStroke: (() -> Void)? = nil, onBackTabKeyStroke: (() -> Void)? = nil
    ) {
        self._value = value
        self.formatter = formatter
        self.placeholder = placeholder
        self.autoFocus = autoFocus
        self.tag = tag
        self._focusTag = focusTag
        self.onChange = onChange
        self.onCommit = onCommit
        self.onTabKeyStroke = onTabKeyStroke
        self.onBackTabKeyStroke = onBackTabKeyStroke
    }
    
    public init(
        _ value: Binding<Value>,
        formatter: Formatter? = nil, placeholder: String,
        autoFocus: Bool = false, tag: Int = 0, focusTag: Binding<Int>,
        onChange: (() -> Void)? = nil, onCommit: (() -> Void)? = nil,
        onTabKeyStroke: (() -> Void)? = nil, onBackTabKeyStroke: (() -> Void)? = nil
    ) {
        self._value = Binding(value)
        self.formatter = formatter
        self.placeholder = placeholder
        self.autoFocus = autoFocus
        self.tag = tag
        self._focusTag = focusTag
        self.onChange = onChange
        self.onCommit = onCommit
        self.onTabKeyStroke = onTabKeyStroke
        self.onBackTabKeyStroke = onBackTabKeyStroke
    }

    public func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.stringValue =
            formatter != nil
                ? formatter!.string(for: value) ?? ""
                : (value != nil ? "\(value!)" : "")
        textField.formatter = formatter
        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        textField.tag = tag
        textField.bezelStyle = .roundedBezel
        return textField
    }

    public func updateNSView(_ nsView: NSTextField, context: Context) {
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
        if let formatter = formatter {
            guard nsView.stringValue != formatter.string(for: value) else {
                return
            }
            nsView.stringValue = formatter.string(for: value) ?? ""
        } else {
            guard nsView.stringValue != value as? String ?? "" else {
                return
            }
            nsView.stringValue = value != nil ? "\(value!)" : ""
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    // MARK: Coordinator
    
    public class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: PlusTextField<Value>

        init(with parent: PlusTextField<Value>) {
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

        // MARK: NSTextFieldDelegate
        
        public func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            updateValue(from: textField.stringValue)
            parent.onChange?()
        }

        public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
            updateValue(from: fieldEditor.string)
            parent.onCommit?()
            return true
        }
        
        private func updateValue(from string: String) {
            if let form = parent.formatter {
                let _tar_pointer = UnsafeMutablePointer<AnyObject>.allocate(capacity: 1)
                let _err_pointer = UnsafeMutablePointer<NSString>.allocate(capacity: 1)
                defer {
                    _tar_pointer.deallocate()
                    _err_pointer.deallocate()
                }
                let tar: AutoreleasingUnsafeMutablePointer<AnyObject?>? = AutoreleasingUnsafeMutablePointer(_tar_pointer)
                let error: AutoreleasingUnsafeMutablePointer<NSString?>? = AutoreleasingUnsafeMutablePointer(_err_pointer)
                form.getObjectValue(tar, for: string, errorDescription: error)
                parent.value = tar?.pointee as? Value
            } else {
                switch parent.value {
                case is NSDecimalNumber:
                    parent.value = NSDecimalNumber(string: string) as? Value
                case is Int:
                    parent.value = Int(string) as? Value
                case is Int32:
                    parent.value = Int32(string) as? Value
                case is Int16:
                    parent.value = Int16(string) as? Value
                case is Float:
                    parent.value = Float(string) as? Value
                default:
                    parent.value = string as? Value
                }
            }
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
        
//        public func textField(_ textField: NSTextField, textView: NSTextView, candidatesForSelectedRange selectedRange: NSRange) -> [Any]? {
//            guard let keyPath = parent.completions?.1,
//                  let completions = parent.completions?.0 else {
//                return nil
//            }
//            return completions.map { $0[keyPath: keyPath] }.filter { $0 == parent.value } as [Any]
//        }
//
//        public func textField(_ textField: NSTextField, textView: NSTextView, shouldSelectCandidateAt index: Int) -> Bool {
//            return true
//        }
    }
}
#endif
