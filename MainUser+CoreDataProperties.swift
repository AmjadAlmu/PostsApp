//
//  MainUser+CoreDataProperties.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 29/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//
//

import Foundation
import CoreData


extension MainUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MainUser> {
        return NSFetchRequest<MainUser>(entityName: "MainUser")
    }

    @NSManaged public var access_token: String?
    @NSManaged public var id: Int32
    @NSManaged public var posts: Post?

}
