//
//  PDFViews.swift
//  PDFViews
//
//  Created by Orijhins on 22/09/2021.
//

import Foundation
import SwiftUI
import PDFKit

@available(macOS 10.15, *)
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

@available(iOS 13.0, *)
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
