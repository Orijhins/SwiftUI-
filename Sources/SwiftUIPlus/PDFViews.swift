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
public struct PlusPDFView: NSViewRepresentable {
    private var data: Data?
    private let autoScales: Bool
    
    public init(_ data: Data?, autoScales: Bool = true) {
        self.data = data
        self.autoScales = autoScales
    }
    
    public func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = autoScales
        if let data = data {
            pdfView.document = PDFDocument(data: data)
        }
        return pdfView
    }
    
    public func updateNSView(_ nsView: PDFView, context: Context) {
        //
    }
}
#else
@available(iOS 13.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct UIPlusPDFView: UIViewRepresentable {
    private var data: Data?
    private let autoScales: Bool
    
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
#endif
