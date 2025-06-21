//
//  Numbers+CoreDataProperties.swift
//  TakarakujiDataBox
//
//  Created by Satoshi Wakita on 2023/10/20.
//
//

import Foundation
import CoreData


extension Numbers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Numbers> {
        return NSFetchRequest<Numbers>(entityName: "Numbers")
    }

    @NSManaged public var numberOfTime: Int32
    @NSManaged public var timestamp: Date?
    @NSManaged public var type: Int32
    @NSManaged public var winingNumber: Int16

}

extension Numbers : Identifiable {

}
