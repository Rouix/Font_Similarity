//
//  ContentView.swift
//  Font_Similarity
//
//  Created by Валерия Огородникова on 02.10.2020.
//

import SwiftUI
import Vision

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
            
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
                        self.viewModel.start()
                    }
                }, label: { Text("Process") }))
                .navigationBarTitle(Text("Vision Image Similarity"), displayMode: .inline)
        }
    }
    
}


