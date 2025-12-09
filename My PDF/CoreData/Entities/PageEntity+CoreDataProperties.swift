//
//  PageEntity+CoreDataProperties.swift
//  My PDF
//
//  Created by Эдвард on 12/9/25.
//
//

public import Foundation
public import CoreData


public typealias PageEntityCoreDataPropertiesSet = NSSet

extension PageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageEntity> {
        return NSFetchRequest<PageEntity>(entityName: "PageEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageData: Data?
    @NSManaged public var pageNumber: Int16
    @NSManaged public var document: DocumentEntity?

}

extension PageEntity : Identifiable {

}
