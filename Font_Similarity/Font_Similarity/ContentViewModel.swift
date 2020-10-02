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
    @Published var sourceImage: UIImage?
    @Published var sourceName: String?
    @Published var modelData: [ModelData] = []
    
    private let fileName = "fontsSimilarity"
    var jsonModel = DomainJson()
    
    init() {
        self.getFontImages()
    }
    
    func setSource(modelData: [ModelData]) {
        let item = modelData.first
        self.sourceImage = item!.image
        self.sourceName = item!.imageName
    }
    
    func saveModelData(modelData: [ModelData]) {
        self.modelData = modelData
        
        self.jsonModel.data[self.sourceName!] = modelData.map({ (item) -> CustomFontModel in
            return CustomFontModel(name: item.imageName)
        })
        
        do {
            let _ = try JSONSerialization.save(jsonObject: self.jsonModel, toFilename: self.fileName)
        } catch {
            print("failed to save")
        }
    }
    
    func loadDataFromFile() {
        do {
            self.jsonModel = try JSONSerialization.loadJSON(withFilename: self.fileName)!
        } catch {
            print("failed to save")
        }
    }
    
    func getFontImages() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path + "/fonts")
        let test2 = items[0..<items.count/2]
        
        for (index, image) in test2.enumerated() {
            let imageURL = URL(fileURLWithPath: path + "/fonts").appendingPathComponent(test2[index])
            self.modelData.append(ModelData(id: index, image: UIImage(contentsOfFile: imageURL.path)!, imageName: image))
        }
        
        self.setSource(modelData: self.modelData)
    }
}


extension ContentViewModel {
    func start() {
        let queue = DispatchQueue(label: "test", attributes: .concurrent)
        let groud = DispatchGroup()
        
        let m1 = self.modelData[0..<self.modelData.count/3]
        let m2 = self.modelData[self.modelData.count/3..<self.modelData.count/3*2]
        let m3 = self.modelData[self.modelData.count/3*2..<self.modelData.count]
        
        var res1 = [ModelData]()
        var res2 = [ModelData]()
        var res3 = [ModelData]()
        
        groud.enter()
        queue.async {
            res1 = self.processImages(modelData: Array(m1), thread: "1")
            groud.leave()
        }
        
        groud.enter()
        queue.async {
            res2 = self.processImages(modelData: Array(m2), thread: "2")
            groud.leave()
        }
        
        groud.enter()
        queue.async {
            res3 = self.processImages(modelData: Array(m3), thread: "3")
            groud.leave()
        }
        
        queue.async {
            groud.wait()
            DispatchQueue.main.async {
                res1.append(contentsOf: res2)
                res1.append(contentsOf: res3)
                self.saveModelData(modelData: res1.sorted(by: {Float($0.distance)! < Float($1.distance)!}))
            }
        }
    }
    
    func processImages(modelData: [ModelData], thread: String) -> [ModelData] {
        guard self.modelData.count > 0 else { return [] }
        
        var observation : VNFeaturePrintObservation?
        var sourceObservation : VNFeaturePrintObservation?
    
        sourceObservation = featureprintObservationForImage(image: self.sourceImage!)
        
        var tempData = modelData
        
        tempData = modelData.enumerated().map { (i,m) in
            var model = m
            print("threa: \(thread) index: \(i)")
            observation = featureprintObservationForImage(image: model.image)
            
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
