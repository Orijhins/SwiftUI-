//
//  PDFViews.swift
//  PDFViews
//
//  Created by Orijhins on 22/09/2021.
//

import SwiftUI
import PDFKit

#if os(macOS)
@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
/**
 A PDFView for macOS
 */
public struct PlusPDFView: NSViewRepresentable {
    ///The Data to display in the PDFView
    public private(set) var document: PDFDocument?
    ///OPTIONAL: If the displayed PDF should autoscale. Default is true
    public let autoScales: Bool
    
    public init(_ data: Data?, autoScales: Bool = true) {
        if let data = data {
            self.document = PDFDocument(data: data)
        } else {
            self.document = PDFDocument()
        }
        self.autoScales = autoScales
    }
    
    public init(_ document: PDFDocument, autoScales: Bool = true) {
        self.document = document
        self.autoScales = autoScales
    }
    
    public func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = autoScales
        pdfView.document = document
        return pdfView
    }
    
    public func updateNSView(_ nsView: PDFView, context: Context) {
        nsView.document = document
    }
}
#else
@available(iOS 13.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
/**
 A PDFView for iOS
 */
public struct UIPlusPDFView: UIViewRepresentable {
    ///The Data to display in the PDFView
    public private(set) var data: Data?
    ///OPTIONAL: If the displayed PDF should autoscale. Default is true
    public let autoScales: Bool
    
    public init(_ data: Data?, autoScales: Bool = true) {
        self.data = data
        self.autoScales = autoScales
    }
    
    public func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = autoScales
        if let data = data {
            pdfView.document = PDFDocument(data: data)
        }
        return pdfView
    }
    
    public func updateUIView(_ uiView: PDFView, context: Context) {
        //
    }
}

@available(iOS 13.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct UIPlusShareView: UIViewControllerRepresentable {
    public let activityItems: [Any]
    public let applicationActivities: [UIActivity]? = nil
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        //
    }
}

@available(iOS 13.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
/**
 A Sharing Preview for the PDF, used to be embedded in the "Share" View
 */
public struct UIPlusPDFPreview: View {
    @Binding var data: Data?
    
    @State private var showShareSheet: Bool = false
    
    public var body: some View {
        VStack {
            UIPlusPDFView(data)
            UIPlusShareButton()
            Spacer()
        }
        .navigationTitle("Votre PDF")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let data = data {
                UIPlusShareView(activityItems: [data])
            }
        }
    }
    
    private func UIPlusShareButton() -> some View {
        Button(action: { showShareSheet.toggle() }) {
            Text("")
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
        }
    }
}
#endif
