//
//  File.swift
//  
//
//  Created by Michael Nyssen on 15/02/2022.
//

import Foundation
import SwiftUI

#if os(macOS)
@available(macOS 10.15, *)
public struct PlusMultilineTextField: NSViewRepresentable {
    public typealias NSViewType = NSScrollView
    
    private var theTextView = NSTextView.scrollableTextView()
    
    //The Value held and displayed by the TextView
    @Binding private var value: NSAttributedString?
    ///OPTIONAL: Set this to true if you want the TextView to be autofocused
    ///when the View is displayed or becomes active. Default is false
    private var autoFocus = false
    ///OPTIONAL: The TextView's Tag, used to navigate through PlusViews
    ///when Tab is pressed e.g. Default is 0
    private var tag: Int = 0
    ///The View's focusTag, which is shared between PlusViews. Update this
    ///one to navigate to a PlusView with the same tag
    @Binding private var focusTag: Int
    ///OPTIONAL: The Delegate Action to execute whenever the Value changes
    private var onChange: (() -> Void)?
    ///OPTIONAL: The Delegate Action to execute when Editing ends
    private var onCommit: (() -> Void)?
    
    @State fileprivate var didFocus = false
    
    public init(
        _ value: Binding<NSAttributedString?>,
        autoFocus: Bool = false, tag: Int = 0, focusTag: Binding<Int>,
        onChange: (() -> Void)? = nil, onCommit: (() -> Void)? = nil
    ) {
        self._value = value
        self.autoFocus = autoFocus
        self.tag = tag
        self._focusTag = focusTag
        self.onChange = onChange
        self.onCommit = onCommit
    }
    
    public init(
        _ value: Binding<NSAttributedString>,
        autoFocus: Bool = false, tag: Int = 0, focusTag: Binding<Int>,
        onChange: (() -> Void)? = nil, onCommit: (() -> Void)? = nil
    ) {
        self._value = Binding(value)
        self.autoFocus = autoFocus
        self.tag = tag
        self._focusTag = focusTag
        self.onChange = onChange
        self.onCommit = onCommit
    }
    
    public func makeNSView(context: Context) -> NSScrollView {
        let textView = theTextView.documentView as! NSTextView
        textView.backgroundColor = .clear
        textView.isEditable = true
        textView.isRichText = true
        theTextView.borderType = .lineBorder
        theTextView.hasHorizontalScroller = false
        theTextView.wantsLayer = true
        theTextView.layer?.cornerRadius = 5
        theTextView.focusRingType = .default
        textView.delegate = context.coordinator
        textView.textStorage?.setAttributedString(value ?? NSAttributedString())
        return theTextView
    }
    
    public func updateNSView(_ nsView: NSScrollView, context: Context) {
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

        if focusTag == tag {
            NSApplication.shared.mainWindow?.perform(
                #selector(NSApplication.shared.mainWindow?.makeFirstResponder(_:)),
                with: nsView,
                afterDelay: 0.0)

            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(1)) {
                self.focusTag = 0
            }
        }
        
        guard let view = nsView.documentView as? NSTextView else { return }

        guard view.attributedString() != value ?? NSAttributedString() else {
            return
        }
        view.textStorage?.setAttributedString(value ?? NSAttributedString())
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: PlusMultilineTextField
        
        var selectedRanges: [NSValue] = []

        init(with parent: PlusMultilineTextField) {
            self.parent = parent
//            super.init()
//
//            NotificationCenter.default.addObserver(
//                self,
//                selector: #selector(handleAppDidBecomeActive(notification:)),
//                name: NSApplication.didBecomeActiveNotification,
//                object: nil)
        }

//        @objc func handleAppDidBecomeActive(notification: Notification) {
//            if parent.autoFocus && !parent.didFocus {
//                DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(1)) {
//                    self.parent.didFocus = false
//                }
//            }
//        }

        // MARK: NSTextViewDelegate
        
        public func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            updateValue(from: textView.attributedString())
        }
        
        public func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            updateValue(from: textView.attributedString())
            parent.onCommit?()
        }
        
        private func updateValue(from attributedString: NSAttributedString) {
            parent.value = attributedString
        }
        
        public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.selectedRanges = textView.selectedRanges
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            updateValue(from: textView.attributedString())
            self.selectedRanges = textView.selectedRanges
            parent.onChange?()
        }
    }
}

public struct PlusTextView: View {
    //The Value held and displayed by the TextView
    @Binding var value: NSAttributedString?
    
    var placeholder: String? = nil
    ///OPTIONAL: Set this to true if you want the TextView to be autofocused
    ///when the View is displayed or becomes active. Default is false
    var autoFocus = false
    ///OPTIONAL: The TextView's Tag, used to navigate through PlusViews
    ///when Tab is pressed e.g. Default is 0
    var tag: Int = 0
    ///The View's focusTag, which is shared between PlusViews. Update this
    ///one to navigate to a PlusView with the same tag
    @Binding var focusTag: Int
    ///OPTIONAL: The Delegate Action to execute whenever the Value changes
    var onChange: (() -> Void)? = nil
    ///OPTIONAL: The Delegate Action to execute when Editing ends
    var onCommit: (() -> Void)? = nil
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            if placeholder != nil && (value == nil || value?.string.isEmpty ?? true ) {
                Text(placeholder!)
                    .foregroundColor(.gray)
                    .padding(.leading, 6)
                    .opacity(0.8)
            }
            PlusMultilineTextField($value, autoFocus: autoFocus, tag: tag, focusTag: $focusTag, onChange: onChange, onCommit: onCommit)
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity)
        }
    }
}
#endif
