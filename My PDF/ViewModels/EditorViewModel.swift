//
//  EditorViewModel.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//
import SwiftUI
import Combine

@MainActor
final class EditorViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var selectedImages: [UIImage] = []
    @Published var documentName: String = ""
    @Published var isLoading = false
    @Published var generatedPDF: PDFDocument?
    @Published var showImagePicker = false
    
    // MARK: - Dependencies
    private let pdfManager = PDFKitManager()
    
    // MARK: - Computed Properties
    var canGeneratePDF: Bool {
        !selectedImages.isEmpty
    }
    
    var displayName: String {
        documentName.isEmpty ? "Untitled Document" : documentName
    }
    
    // MARK: - Actions
    func addImages(_ images: [UIImage]) {
        selectedImages.append(contentsOf: images)
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    func moveImage(from source: IndexSet, to destination: Int) {
        selectedImages.move(fromOffsets: source, toOffset: destination)
    }
    
    func generatePDF() async {
        guard canGeneratePDF else { return }

        await MainActor.run {
            isLoading = true
        }

        let images = selectedImages
        let name = displayName
        let manager = pdfManager

        let document = await Task.detached(priority: .userInitiated) {
            try? await manager.createPDF(from: images, name: name)
        }.value

        await MainActor.run {
            if let document = document {
                self.generatedPDF = document
            }
            self.isLoading = false
        }
    }

    
    func reset() {
        selectedImages = []
        documentName = ""
        generatedPDF = nil
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

