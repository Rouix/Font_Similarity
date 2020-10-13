//
//  ContentViewModel.swift
//  Font_Similarity
//
//  Created by Валерия Огородникова on 02.10.2020.
//

import Foundation
import UIKit
import Vision

class ContentViewModel: ObservableObject {
    var modelData: [ModelData] = []
    
    private let fileName = "fontsSimilarity"
    var jsonModel = DomainJson()
    
    init() {
        self.loadFonts()
        self.startAlg()
    }
    
    func loadFonts() {
        
        do {
            let customFonts = try JSONSerialization.loadFonts()
            var index = 0
            customFonts.forEach { (name) in
                if let font = UIFont(name: name, size: 24) {
                    self.modelData.append(ModelData(id: index, image: FontCoverter.transformFontToImage(font: font)!, imageName: name as String))
                    index += 1
                }
            }
        } catch {
            print("failed to load fonts name")
        }
        
    }
    
    func saveModelData(data: [ModelData], sourceModel: ModelData) {
        self.jsonModel.data[sourceModel.imageName] = data.map({ (item) -> CustomFontModel in
            return CustomFontModel(name: item.imageName)
        })
        
        do {
            let _ = try JSONSerialization.save(jsonObject: self.jsonModel, toFilename: self.fileName)
            self.jsonModel.data.removeAll()
        } catch {
            print("failed to save")
        }
    }
        
    func startAlg() {
        let sourceM1 = self.modelData[0..<self.modelData.count / 3]
        let sourceM2 = self.modelData[self.modelData.count / 3..<self.modelData.count / 3 * 2]
        let sourceM3 = self.modelData[self.modelData.count / 3 * 2..<self.modelData.count]
        
        let queue = OperationQueue()
        
        let operation1 = BlockOperation {
            print("operation1")
            for model in sourceM1 {
                self.start(sourceModel: model)
            }
        }
 
        let operation2 = BlockOperation {
            print("operation2")
            for model in sourceM2 {
                self.start(sourceModel: model)
            }
        }

        let operation3 = BlockOperation {
            print("operation3")
            for model in sourceM3 {
                self.start(sourceModel: model)
            }
        }
        
        queue.maxConcurrentOperationCount = 3
        queue.addOperation(operation1)
        queue.addOperation(operation2)
        queue.addOperation(operation3)
    }
            
}


extension ContentViewModel {
    func start(sourceModel: ModelData) {
        var m1 = self.modelData[0..<self.modelData.count]
        m1.removeAll(where: {$0.id == sourceModel.id })
        
        var res1 = [ModelData]()
        res1 = self.processImages(modelData: Array(m1), sourceModel: sourceModel, thread: sourceModel.imageName)
        
        self.saveModelData(data: res1.sorted(by: { Float($0.distance)! < Float($1.distance)! }), sourceModel: sourceModel)

    }
    
    func processImages(modelData: [ModelData], sourceModel: ModelData, thread: String) -> [ModelData] {
        guard self.modelData.count > 0 else { return [] }
        print("thread \(thread)")
        
        var observation : VNFeaturePrintObservation?
        var sourceObservation : VNFeaturePrintObservation?
    
        sourceObservation = featureprintObservationForImage(image: sourceModel.image)
        
        var tempData = modelData
        
        tempData = modelData.enumerated().map { (i,m) in
            var model = m
            observation = featureprintObservationForImage(image: sourceModel.image)
            
            do {
                var distance = Float(0)
                if let sourceObservation = sourceObservation {
                    try observation?.computeDistance(&distance, to: sourceObservation)
                    model.distance = "\(distance)"
                }
            } catch {
                print("errror occurred..")
            }
                
            
            return model
        }
        return tempData
    }
    
    func featureprintObservationForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
}
