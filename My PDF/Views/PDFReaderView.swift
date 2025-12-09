
//
//  PDFReader.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//
import SwiftUI

struct PDFReaderView: View {
    @StateObject private var viewModel: PDFReaderViewModel
    @Binding var isPresented: Bool  //
    let onDismiss: (() -> Void)?
    
    init(document: PDFDocument, isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: PDFReaderViewModel(document: document))
        _isPresented = isPresented
        self.onDismiss = onDismiss
    }
    
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                topBar
                
                // PDF Viewer
                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(viewModel.document.pages.indices, id: \.self) { index in
                        pageView(at: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom Controls
                bottomControls
            }
        }
        .navigationBarHidden(true)
        .alert("Delete Page", isPresented: $viewModel.showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deletePage()
                }
            }
        } message: {
            Text("Are you sure you want to delete this page?")
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let url = viewModel.shareURL {
                ShareSheet(items: [url])
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
    }
    
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                isPresented = false
                onDismiss?()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
            }
            
            Spacer()
            
            Text(viewModel.document.name)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Placeholder for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal)
        .background(Color.black.opacity(0.8))
    }
    
    
    // MARK: - Page View
    private func pageView(at index: Int) -> some View {
        Group {
            if let page = viewModel.document.pages[safe: index],
               let image = UIImage(data: page.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .background(Color.black)
            } else {
                Text("Failed to load page")
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Page Indicator
            Text(viewModel.pageIndicator)
                .font(.subheadline)
                .foregroundColor(.white)
            
            // Action Buttons
            HStack(spacing: 20) {
                // Delete Page
                Button {
                    viewModel.showDeleteAlert = true
                } label: {
                    VStack {
                        Image(systemName: "trash")
                            .font(.title2)
                        Text("Delete")
                            .font(.caption)
                    }
                    .foregroundColor(viewModel.canDeletePage ? .red : .gray)
                }
                .disabled(!viewModel.canDeletePage)
                
                Spacer()
                
                // Save Document
                Button {
                    Task {
                        await viewModel.saveDocument()
                    }
                } label: {
                    VStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                        Text("Save")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }
                
                Spacer()
                
                // Share Document
                Button {
                    Task {
                        await viewModel.shareDocument()
                    }
                } label: {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                        Text("Share")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 20)
        .background(Color.black.opacity(0.8))
    }
}
