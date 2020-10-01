//
//  ContentViewModel.swift
//  ImageClassifier
//
//  Created by Валерия Огородникова on 01.10.2020.
//

import Foundation
import UIKit

class ContentViewModel: ObservableObject {
    @Published var sourceImage: UIImage?
    @Published var sourceName: String?
    @Published var modelData: [ModelData] = []
    
    var jsonModel = DomainJson()
    
    func setSource(modelData: [ModelData]) {
        let item = modelData.first
        self.sourceImage = item!.image
        self.sourceName = item!.imageName
    }
    
    func setModelData(modelData: [ModelData]) {
        self.modelData = modelData
        
        self.jsonModel.data[self.sourceName!] = modelData.map({ (item) -> CustomFontModel in
            return CustomFontModel(name: item.imageName)
        })
        
        do {
            let _ = try JSONSerialization.save(jsonObject: self.jsonModel, toFilename: "result")
        } catch {
            print("failed to save")
        }
    }
    
    func getData() {
        do {
            self.jsonModel = try JSONSerialization.loadJSON(withFilename: "result")!
        } catch {
            print("failed to save")
        }
    }
}
