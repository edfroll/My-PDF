//
//  DocumentEntity+CoreDataProperties.swift
//  My PDF
//
//  Created by Эдвард on 12/9/25.
//
//

public import Foundation
public import CoreData


public typealias DocumentEntityCoreDataPropertiesSet = NSSet

extension DocumentEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentEntity> {
        return NSFetchRequest<DocumentEntity>(entityName: "DocumentEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var pages: NSSet?

}

// MARK: Generated accessors for pages
extension DocumentEntity {

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: PageEntity)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: PageEntity)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSSet)

}

extension DocumentEntity : Identifiable {

}
