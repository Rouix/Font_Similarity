//
//  FontCoverter.swift
//  Font_Similarity
//
//  Created by Валерия Огородникова on 13.10.2020.
//

import Foundation
//import AppKit
//import AVKit
import UIKit


class FontCoverter {
    
    //MACOS
//    static func transformFontToImage(font: NSFont) -> NSImage? {
//        let view = NSView()
//        view.layer?.backgroundColor = .white
//        let label = NSTextField(labelWithString: "Laseg \n dhum \n Hloiv")
//        label.textColor = .black
//        label.alignment = .center
//        label.maximumNumberOfLines = 3
//        label.font = font
//
//        view.translatesAutoresizingMaskIntoConstraints = false
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(label)
//
//        NSLayoutConstraint.activate([
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//
//            view.heightAnchor.constraint(equalToConstant: 150),
//            view.widthAnchor.constraint(equalToConstant: 150)
//        ])
//
//        view.layoutSubtreeIfNeeded()
//        return view.screenshot()
//    }
    
    static func transformFontToImage(font: UIFont) -> UIImage? {
        let view = UIView()
        view.backgroundColor = .white
        let label = UILabel()
        label.text = "Laseg \n dhum \n Hloiv"
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = font
        
        view.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            view.heightAnchor.constraint(equalToConstant: 150),
            view.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        view.layoutSubviews()
        return view.screenshot()
    }
}


//MACOS
//extension NSView {
//    func screenshot() -> NSImage? {
//        return NSImage(data: self.dataWithPDF(inside: self.bounds))
//    }
//}

extension UIView {
    func screenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}
