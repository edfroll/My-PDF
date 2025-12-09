//
//  PDFKitManager.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//

import PDFKit

final class PDFKitManager {
    
    // MARK: - PDF Creation
    func createPDF(from images: [UIImage], name: String) throws -> PDFDocument {
        guard !images.isEmpty else {
            throw PDFError.noImages
        }
        
        let pages = images.enumerated().map { index, image in
            // Compress image to reduce storage size
            let compressedData = image.jpegData(compressionQuality: 0.7) ?? Data()
            
            return PDFPageModel(
                id: UUID(),
                imageData: compressedData,
                pageNumber: index
                )
        }
        
        let document = PDFDocument(
            id: UUID(),
            name: name.isEmpty ? "Document \(Date().formatted())" : name,
            createdAt: Date(),
            pages: pages
        )
        
        print("✅ PDF created: \(document.name) with \(pages.count) pages")
        return document
    }
    
    // MARK: - PDF Merging
    func mergePDFs(_ documents: [PDFDocument], name: String) throws -> PDFDocument {
        guard !documents.isEmpty else {
            throw PDFError.noDocuments
        }
        
        var allPages: [PDFPageModel] = []
        var pageNumber = 0
        
        for document in documents {
            for page in document.pages {
                let newPage = PDFPageModel(
                    id: UUID(),
                    imageData: page.imageData,
                    pageNumber: pageNumber
                )
                allPages.append(newPage)
                pageNumber += 1
            }
        }
        
        let mergedDocument = PDFDocument(
            id: UUID(),
            name: name.isEmpty ? "Merged Document" : name,
            createdAt: Date(),
            pages: allPages
        )
        
        print("✅ Merged \(documents.count) documents into '\(mergedDocument.name)'")
        return mergedDocument
    }
    
    // MARK: - PDF Export
    func exportToFile(_ document: PDFDocument) throws -> URL {
        let pdfKitDocument = PDFKit.PDFDocument()
        
        for page in document.pages.sorted(by: { $0.pageNumber < $1.pageNumber }) {
            guard let image = UIImage(data: page.imageData) else {
                print("⚠️ Failed to create image from data")
                continue
            }
            guard let pdfKitPage = PDFKit.PDFPage(image: image) else {
                print("⚠️ Failed to create PDF page from image")
                continue
            }
            
            pdfKitDocument.insert(pdfKitPage, at: pdfKitDocument.pageCount)
        }
        
        guard pdfKitDocument.pageCount > 0 else {
            throw PDFError.exportFailed
        }
        
        let fileName = "\(document.name).pdf"
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        
        try? FileManager.default.removeItem(at: tempURL)
        
        guard pdfKitDocument.write(to: tempURL) else {
            throw PDFError.exportFailed
        }
        
        print("✅ PDF Exported to: \(tempURL.path)")
        return tempURL
    }
    
    // MARK: - Delete Page
    func deletePage(from document: inout PDFDocument, at index: Int) throws {
        guard index >= 0 && index < document.pages.count else {
            throw PDFError.invalidPageIndex
        }
        
        document.pages.remove(at: index)
        
        // Re-index remaining pages
        for i in 0..<document.pages.count {
            document.pages[i].pageNumber = i
        }
        
        print("✅ Deleted page \(index + 1) from '\(document.name)'")
    }
}
enum PDFError: LocalizedError {
    case noImages
    case noDocuments
    case exportFailed
    case invalidPageIndex
    
    var errorDescription: String? {
        switch self {
        case .noImages:
            return "No images provided for PDF creation"
        case .noDocuments:
            return "No documents provided for merging"
        case .exportFailed:
            return "Failed to export PDF file"
        case .invalidPageIndex:
            return "Invalid page index"
        }
    }
}
