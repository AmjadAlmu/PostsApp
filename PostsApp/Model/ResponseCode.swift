//
//  ResponseCode.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 28/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//

import Foundation

enum ResponseCode{
    case post_success
    case get_success
    
    var code: Int {
        switch self {
        case .post_success:
            return 201
        case .get_success:
            return 200
        }
    }
}
