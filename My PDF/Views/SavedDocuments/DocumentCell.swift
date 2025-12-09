//
//  DocumentCell.swift
//  My PDF
//
//  Created by Эдвард on 12/9/25.
//

import SwiftUI

struct DocumentCell: View {
    let document: PDFDocument
    let isMergeMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void
    let onMerge: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Thumbnail
                thumbnail
                
                // Document Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(document.name)
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text(PDFDocument.fileExtension)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(document.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(document.pageCount) \(document.pageCount == 1 ? "page" : "pages")")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Selection indicator (merge mode)
                if isMergeMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .contextMenu {
            if !isMergeMode {
                contextMenuButtons
            }
        }
    }
    
    // MARK: - Thumbnail
    private var thumbnail: some View {
        Group {
            if let thumbnailData = document.thumbnail,
               let image = UIImage(data: thumbnailData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 80)
                    .cornerRadius(8)
                    .overlay {
                        Image(systemName: "doc.text")
                            .foregroundColor(.gray)
                    }
            }
        }
    }
    
    // MARK: - Context Menu
    private var contextMenuButtons: some View {
        Group {
            Button {
                onShare()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Button {
                onMerge()
            } label: {
                Label("Merge", systemImage: "doc.on.doc")
            }
            
            Divider()
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
