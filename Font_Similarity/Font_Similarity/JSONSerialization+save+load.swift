//
//  JSONSerialization+save+load.swift
//  Font_Similarity
//
//  Created by Валерия Огородникова on 02.10.2020.
//

import Foundation
extension JSONSerialization {
    
    static func loadJSON(withFilename filename: String) throws -> DomainJson? {
        //for ios
//        let fm = FileManager.default
//        let urls = fm.urls(for: .allApplicationsDirectory, in: .allDomainsMask)
        
        //for macos
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
    
    //FOR MACOS
//    static func loadFonts() throws -> [String] {
//        let fileManager = FileManager.default
//        let documentsURL = Bundle.main.bundleURL
//        let enumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: documentsURL.path)!
//
//        var result = [String]()
//
//        while let element = enumerator.nextObject() as? String {
//            if element.hasSuffix("ttf") {
//                var path = element.replacingOccurrences(of: ".ttf", with: "")
//                var array = path.split(separator: "/")
//                result.append(String(array.last!))
//            }
//        }
//
//        return result
//    }
    
    //FOR IOS
    static func loadFonts() throws -> [String] {
        let fm = FileManager.default
        let filePath = Bundle.main.resourcePath!
        let items = try fm.contentsOfDirectory(atPath: filePath)
        let ttfFiles = items.filter({$0.contains("ttf")})
        return ttfFiles.map { (ttfFile) -> String in
            return ttfFile.replacingOccurrences(of: ".ttf", with: "")
        }
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
            
            do {
                var jsonFile = try JSONSerialization.loadJSON(withFilename: filename)
                let  imJson = jsonObject.data
                jsonFile!.data.merge(dict: imJson)
                let data = try! encoder.encode(jsonFile)
                try data.write(to: fileURL, options: [.atomicWrite])
                return true
            } catch {
                return false
            }

        }
        
        return false
    }
}


extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            self[k] = v
        }
    }
}
