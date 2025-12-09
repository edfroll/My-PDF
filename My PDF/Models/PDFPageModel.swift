//
//  PDFPage.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//

import Foundation

struct PDFPageModel: Identifiable, Equatable, Hashable {
    let id: UUID
    var imageData: Data
    var pageNumber: Int
    
    init(id: UUID = UUID(), imageData: Data, pageNumber: Int) {
        self.id = id
        self.imageData = imageData
        self.pageNumber = pageNumber
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)  // Хешируем только по ID, не по imageData
    }
}
