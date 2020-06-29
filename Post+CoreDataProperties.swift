//
//  Post+CoreDataProperties.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 29/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var title: String?
    @NSManaged public var details: String?
    @NSManaged public var id: Int32
    @NSManaged public var main_user: MainUser?

}
