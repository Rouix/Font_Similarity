//
//  ContentView.swift
//  ImageClassifier
//
//  Created by Валерия Огородникова on 01.10.2020.
//

import SwiftUI
import Vision

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
        
    func getImages() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path + "/fonts")
        let test2 = items[0..<items.count/2]
        
        for (index, image) in test2.enumerated() {
            let imageURL = URL(fileURLWithPath: path + "/fonts").appendingPathComponent(test2[index])
            self.viewModel.modelData.append(ModelData(id: index, image: UIImage(contentsOfFile: imageURL.path)!, imageName: image))
        }
        
        self.viewModel.setSource(modelData: self.viewModel.modelData)
    }
    
    var body: some View {
        NavigationView{
            VStack() {
                if self.viewModel.modelData.count > 0 {
                    HStack {
                        Text(self.viewModel.sourceName!)
                        Image(uiImage: self.viewModel.sourceImage!)
                            .resizable()
                            .frame(width: 150.0, height: 150.0)
                            .scaledToFit()
                    }.frame(height: 150)
                }
                
            List{
                ForEach(self.viewModel.modelData, id: \.id) {
                    model in
                    HStack {
                        Text(model.distance)
                            .padding(10)
                        Text(model.imageName)
                        
                        Image(uiImage: model.image)
                            .resizable()
                            .frame(width: 100.0, height: 100.0)
                            .scaledToFit()
                    }
                }
            }
                
            }.navigationBarItems(
                trailing: Button(action: {
                    DispatchQueue.global().async {
                        self.start()
                    }
                }, label: { Text("Process") }))
                .navigationBarTitle(Text("Vision Image Similarity"), displayMode: .inline)
        }
        .onAppear {
            self.getImages()
        }
    }
    
    func start() {
        let queue = DispatchQueue(label: "test", attributes: .concurrent)
        let groud = DispatchGroup()
        
        let m1 = self.viewModel.modelData[0..<self.viewModel.modelData.count/3]
        let m2 = self.viewModel.modelData[self.viewModel.modelData.count/3..<self.viewModel.modelData.count/3*2]
        let m3 = self.viewModel.modelData[self.viewModel.modelData.count/3*2..<self.viewModel.modelData.count]
        
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
                self.viewModel.setModelData(modelData: res1.sorted(by: {Float($0.distance)! < Float($1.distance)!}))
            }
        }
    }
    
    func processImages(modelData: [ModelData], thread: String) -> [ModelData] {
        
        guard self.viewModel.modelData.count > 0 else {
            return []
        }
        
        var observation : VNFeaturePrintObservation?
        var sourceObservation : VNFeaturePrintObservation?
    
        sourceObservation = featureprintObservationForImage(image: self.viewModel.sourceImage!)
        
        var tempData = modelData
        
        tempData = modelData.enumerated().map { (i,m) in
            var model = m
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

