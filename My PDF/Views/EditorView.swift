//
//  EditorView.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//
import SwiftUI
import PhotosUI

struct EditorView: View {
    @StateObject private var viewModel = EditorViewModel()
    @State private var isNavigationActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Document Name Input
                        documentNameSection
                        
                        // Selected Images Grid
                        if !viewModel.selectedImages.isEmpty {
                            selectedImagesSection
                        } else {
                            emptyStateView
                        }
                    }
                    .padding()
                }
                .onTapGesture {
                    viewModel.hideKeyboard()
                }
                
                NavigationLink(isActive: $isNavigationActive) {
                    if let document = viewModel.generatedPDF {
                        PDFReaderView(document: document, isPresented: $isNavigationActive)
                    }
                } label: {
                    EmptyView()
                }
                .opacity(0)
                
                // Action Buttons (Floating)
                VStack {
                    Spacer()
                    actionButtons
                }
            }
            .navigationTitle("Create PDF")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showImagePicker) {
                PHPicker(selectedImages: $viewModel.selectedImages) {
                    // Post-load if needed
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
        }
    }
    
    // MARK: - Document Name Section
    private var documentNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Document Name")
                .font(.headline)
                .foregroundColor(.secondary)
            
            TextField("Enter document name", text: $viewModel.documentName)
                .textFieldStyle(.automatic)
                .autocorrectionDisabled()
        }
    }
    
    // MARK: - Selected Images Section
    private var selectedImagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Selected Images")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(viewModel.selectedImages.count) \(viewModel.selectedImages.count == 1 ? "image" : "images")")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                    imageCell(at: index)
                }
            }
        }
    }
    
    private func imageCell(at index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: viewModel.selectedImages[index])
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Remove Button
            Button {
                withAnimation {
                    viewModel.removeImage(at: index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.red.clipShape(Circle()))
                    .font(.title3)
            }
            .offset(x: 5, y: -5)
            
            // Page Number Badge
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(index + 1)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                }
            }
            .padding(4)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No images selected")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Tap 'Add Photos' to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Add Photos Button
            Button {
                viewModel.showImagePicker = true
            } label: {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Add Photos")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(.capsule)
            }
            
            // Generate PDF Button
            if viewModel.canGeneratePDF {
                Button {
                    Task {
                        await viewModel.generatePDF()
                        if viewModel.generatedPDF != nil {
                            print("generatedPDF != nil")
                            isNavigationActive = true
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Generate PDF")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(.capsule)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

