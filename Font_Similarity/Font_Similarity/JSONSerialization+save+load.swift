//
//  JSONSerialization+save+load.swift
//  Font_Similarity
//
//  Created by Валерия Огородникова on 02.10.2020.
//

import Foundation

extension JSONSerialization {
    
    static func loadJSON(withFilename filename: String) throws -> DomainJson? {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let myStruct = try! decoder.decode(DomainJson.self, from: data)
            return myStruct
        }
        return nil
    }
    
    static func save(jsonObject: DomainJson, toFilename filename: String) throws -> Bool {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")
            
            print("url: \(fileURL)")
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try! encoder.encode(jsonObject)
            try data.write(to: fileURL, options: [.atomicWrite])
            return true
        }
        
        return false
    }
}
