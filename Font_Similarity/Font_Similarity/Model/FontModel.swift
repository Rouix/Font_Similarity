//
//  FontModel.swift
//  Font_Similarity
//
//  Created by Валерия Огородникова on 02.10.2020.
//

import Foundation
import UIKit

struct DomainJson: Codable {
    var data = Dictionary<String, [CustomFontModel]>()
}

struct CustomFontModel: Codable {
    var name: String
    
    init(name: String) {
        self.name = name
    }

}

struct ModelData: Identifiable {
    public let id: Int
    public var image: UIImage
    public var imageName: String
    public var distance : String = "NA"
}
