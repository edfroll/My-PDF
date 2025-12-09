//
//  SavedDocumentsViewModel.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//

import SwiftUI
import Combine

@MainActor
final class SavedDocumentsViewModel: ObservableObject {
    // MARK: - Published State
    @Published var documents: [PDFDocument] = []
    @Published var isLoading = false
    @Published var selectedDocumentsForMerge: Set<UUID> = []
    @Published var isMergeMode = false
    @Published var showMergeNameAlert = false
    @Published var mergeDocumentName = ""
    
    // MARK: - Dependencies
    private let coreDataManager = CoreDataManager.shared
    private let pdfManager = PDFKitManager()
    
    // MARK: - Computed Properties
    var canMerge: Bool {
        selectedDocumentsForMerge.count >= 2
    }
    
    var isEmpty: Bool {
        documents.isEmpty
    }
    
    // MARK: - Lifecycle
    func onAppear() {
        Task {
            await loadDocuments()
        }
    }
    
    // MARK: - Actions
    func loadDocuments() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            documents = try await coreDataManager.fetchAllDocuments()
            print("✅ Loaded \(documents.count) documents")
        } catch {
            print("❌ Load documents failed: \(error.localizedDescription)")
            documents = []
        }
    }
    
    func deleteDocument(_ document: PDFDocument) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await coreDataManager.deleteDocument(document)
            await loadDocuments()
        } catch {
            print("❌ Delete document failed: \(error.localizedDescription)")
        }
    }
    
    func shareDocument(_ document: PDFDocument) -> URL? {
        do {
            let url = try pdfManager.exportToFile(document)
            return url
        } catch {
            print("❌ Share document failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Merge Actions
    func enterMergeMode() {
        isMergeMode = true
        selectedDocumentsForMerge.removeAll()
    }
    
    func exitMergeMode() {
        isMergeMode = false
        selectedDocumentsForMerge.removeAll()
    }
    
    func toggleDocumentSelection(_ documentId: UUID) {
        if selectedDocumentsForMerge.contains(documentId) {
            selectedDocumentsForMerge.remove(documentId)
        } else {
            selectedDocumentsForMerge.insert(documentId)
        }
    }
    
    func mergeSelectedDocuments() async {
        guard canMerge else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let documentsToMerge = documents.filter { selectedDocumentsForMerge.contains($0.id) }
            .sorted { $0.createdAt < $1.createdAt } // Merge in chronological order
        
        do {
            let mergedDocument = try pdfManager.mergePDFs(
                documentsToMerge,
                name: mergeDocumentName.isEmpty ? "Merged Document" : mergeDocumentName
            )
            
            try await coreDataManager.saveDocument(mergedDocument)
            
            // Reset merge state
            exitMergeMode()
            mergeDocumentName = ""
            
            // Reload documents
            await loadDocuments()
            
            print("✅ Documents merged successfully")
        } catch {
            print("❌ Merge failed: \(error.localizedDescription)")
        }
    }
}
