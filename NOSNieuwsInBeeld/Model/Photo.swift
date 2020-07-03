//
//  Photo.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 29/06/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import Foundation


struct Photo: Codable, Identifiable
{
    struct Format: Codable
    {
        struct URL: Codable
        {
            var jpg: Foundation.URL
        }
        
        var width: Int
        var height: Int
        var url: URL
    }
    
    var id: String
    var title: String
    var description: String
    var copyright: String
    var formats: [Format]
}
