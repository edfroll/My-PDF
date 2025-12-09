//
//  PDFDocument.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//

// Models/PDFDocument.swift

import Foundation

struct PDFDocument: Identifiable, Equatable, Hashable {
    static let fileExtension = "PDF"
    
    let id: UUID
    var name: String
    let createdAt: Date
    var pages: [PDFPageModel]
    
    init(id: UUID = UUID(), name: String, createdAt: Date = Date(), pages: [PDFPageModel] = []) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.pages = pages
    }
    
    // MARK: - Computed Properties
    var pageCount: Int {
        pages.count
    }
    
    var thumbnail: Data? {
        pages.first?.imageData
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
