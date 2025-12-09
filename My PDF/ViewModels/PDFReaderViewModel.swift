//
//  PDFReaderViewModel.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//
import SwiftUI
import Combine

@MainActor
final class PDFReaderViewModel: ObservableObject {
    // MARK: - Published State
    @Published var document: PDFDocument
    @Published var currentPageIndex: Int = 0
    @Published var isLoading = false
    @Published var showDeleteAlert = false
    @Published var showShareSheet = false
    @Published var shareURL: URL?
    
    // MARK: - Dependencies
    private let pdfManager = PDFKitManager()
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Computed Properties
    var currentPage: PDFPageModel? {
        guard currentPageIndex < document.pages.count else { return nil }
        return document.pages[currentPageIndex]
    }
    
    var pageIndicator: String {
        guard !document.pages.isEmpty else { return "0 / 0" }
        return "\(currentPageIndex + 1) / \(document.pages.count)"
    }
    
    var canDeletePage: Bool {
        document.pages.count > 1
    }
    
    // MARK: - Init
    init(document: PDFDocument) {
        self.document = document
    }
    
    // MARK: - Actions
    func deletePage() async {
        guard canDeletePage else {
            print("⚠️ Cannot delete last page")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let indexToDelete = currentPageIndex
        
        do {
            try pdfManager.deletePage(from: &document, at: indexToDelete)
            
            // Adjust current page index
            if currentPageIndex >= document.pages.count {
                currentPageIndex = max(0, document.pages.count - 1)
            }
            
            print("✅ Page deleted successfully")
        } catch {
            print("❌ Delete page failed: \(error.localizedDescription)")
        }
    }
    
    func saveDocument() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await coreDataManager.saveDocument(document)
            print("✅ Document saved: \(document.name)")
        } catch {
            print("❌ Save failed: \(error.localizedDescription)")
        }
    }
    
    func shareDocument() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let url = try pdfManager.exportToFile(document)
            shareURL = url
            showShareSheet = true
        } catch {
            print("❌ Share failed: \(error.localizedDescription)")
        }
    }
    
    func goToNextPage() {
        guard currentPageIndex < document.pages.count - 1 else { return }
        withAnimation {
            currentPageIndex += 1
        }
    }
    
    func goToPreviousPage() {
        guard currentPageIndex > 0 else { return }
        withAnimation {
            currentPageIndex -= 1
        }
    }
}
