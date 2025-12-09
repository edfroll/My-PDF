//
//  SavedDocumentsView.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//
import SwiftUI

struct SavedDocumentsView: View {
    @StateObject private var viewModel = SavedDocumentsViewModel()
    @State private var selectedDocument: PDFDocument?
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    @State private var isReaderPresented = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    documentsList
                }
            }
            
            .navigationTitle("Saved Documents")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.isEmpty {
                        mergeButton
                    }
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = shareURL {
                    ShareSheet(items: [url])
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .alert("Merge Documents", isPresented: $viewModel.showMergeNameAlert) {
                TextField("Merged document name", text: $viewModel.mergeDocumentName)
                Button("Cancel", role: .cancel) {
                    viewModel.exitMergeMode()
                }
                Button("Merge") {
                    Task {
                        await viewModel.mergeSelectedDocuments()
                    }
                }
                .disabled(!viewModel.canMerge)
            } message: {
                Text("Enter a name for the merged document")
            }
            
            .background(
                NavigationLink(isActive: $isReaderPresented) {
                    if let document = selectedDocument {
                        PDFReaderView(document: document,
                                      isPresented: $isReaderPresented,
                                      onDismiss: { }// optional cleanup
                        )
                    }
                } label: {
                    EmptyView()
                }
                    .hidden()
            )
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Saved Documents")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create a PDF to see it here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Documents List
    private var documentsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isMergeMode {
                    mergeBanner
                }
                
                ForEach(viewModel.documents) { document in
                    DocumentCell(
                        document: document,
                        isMergeMode: viewModel.isMergeMode,
                        isSelected: viewModel.selectedDocumentsForMerge.contains(document.id),
                        onTap: {
                            if viewModel.isMergeMode {
                                viewModel.toggleDocumentSelection(document.id)
                            } else {
                                selectedDocument = document
                                isReaderPresented = true
                            }
                        },
                        onShare: {
                            shareURL = viewModel.shareDocument(document)
                            showShareSheet = true
                        },
                        onDelete: {
                            Task {
                                await viewModel.deleteDocument(document)
                            }
                        },
                        onMerge: {
                            viewModel.enterMergeMode()
                            viewModel.toggleDocumentSelection(document.id)
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Merge Banner
    private var mergeBanner: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "doc.on.doc")
                    .foregroundColor(.blue)
                
                Text("Select documents to merge")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.selectedDocumentsForMerge.count) selected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    viewModel.exitMergeMode()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Merge") {
                    viewModel.showMergeNameAlert = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canMerge)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Merge Button
    private var mergeButton: some View {
        Button {
            viewModel.enterMergeMode()
        } label: {
            Image(systemName: "doc.on.doc")
        }
    }
}
