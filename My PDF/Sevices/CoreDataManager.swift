//
//  CoreDataManager.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//
// Services/CoreDataManager.swift

import CoreData
import Foundation

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PDFDataModel")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("❌ CoreData error: \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error)")
            }
            print("✅ CoreData loaded: \(storeDescription)")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    private func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
            print("✅ CoreData context saved")
        }
    }
    
    // MARK: - CRUD Operations
    func saveDocument(_ document: PDFDocument) async throws {
        try await context.perform { [weak self] in
            guard let self else { return }
            
            // Check if document already exists
            let fetchRequest = DocumentEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)
            
            let existingDocuments = try self.context.fetch(fetchRequest)
            
            let entity: DocumentEntity
            if let existing = existingDocuments.first {
                // Update existing
                entity = existing
                print("ℹ️ Updating existing document: \(document.name)")
            } else {
                // Create new
                entity = DocumentEntity(context: self.context)
                entity.id = document.id
                print("ℹ️ Creating new document: \(document.name)")
            }
            
            // Update properties
            entity.name = document.name
            entity.createdAt = document.createdAt
            
            // Delete old pages
            if let oldPages = entity.pages?.allObjects as? [PageEntity] {
                oldPages.forEach { self.context.delete($0) }
            }
            
            // Create new pages
            var pageEntities = Set<PageEntity>()
            for page in document.pages {
                let pageEntity = PageEntity(context: self.context)
                pageEntity.id = page.id
                pageEntity.imageData = page.imageData
                pageEntity.pageNumber = Int16(page.pageNumber)
                pageEntity.document = entity
                pageEntities.insert(pageEntity)
            }
            entity.pages = pageEntities as NSSet
            
            try self.saveContext()
        }
    }
    
    func fetchAllDocuments() async throws -> [PDFDocument] {
        try await context.perform { [weak self] in
            guard let self else { return [] }
            
            let request = DocumentEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let entities = try self.context.fetch(request)
            let documents = entities.compactMap { self.toDomain($0) }
            
            print("✅ Fetched \(documents.count) documents")
            return documents
        }
    }
    
    func deleteDocument(_ document: PDFDocument) async throws {
        try await context.perform { [weak self] in
            guard let self else { return }
            
            let request = DocumentEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)
            
            if let entity = try self.context.fetch(request).first {
                self.context.delete(entity)
                try self.saveContext()
                print("✅ Deleted document: \(document.name)")
            }
        }
    }
    
    // MARK: - Mapping
    private func toDomain(_ entity: DocumentEntity) -> PDFDocument? {
        guard let id = entity.id,
              let name = entity.name,
              let createdAt = entity.createdAt else {
            print("⚠️ Invalid document entity")
            return nil
        }
        
        let pages = (entity.pages?.allObjects as? [PageEntity] ?? [])
            .sorted { $0.pageNumber < $1.pageNumber }
            .compactMap { pageEntity -> PDFPageModel? in
                guard let pageId = pageEntity.id,
                      let imageData = pageEntity.imageData else {
                    return nil
                }
                
                return PDFPageModel(
                    id: pageId,
                    imageData: imageData,
                    pageNumber: Int(pageEntity.pageNumber)
                )
            }
        
        return PDFDocument(
            id: id,
            name: name,
            createdAt: createdAt,
            pages: pages
        )
    }
}
