//
//  Memory.swift
//  myMemories
//
//  Created by dainf on 18/08/17.
//  Copyright © 2017 br.utfpr. All rights reserved.
//

import UIKit

import CoreSpotlight
import MobileCoreServices

class Memory: NSObject {

    static func indexMemory(memory: URL, text: String) {
        
        let attributeset = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        
        attributeset.title = "myMemories App"
        attributeset.contentDescription = text
        attributeset.thumbnailURL = URLHelper.thumbailURL(for: memory)
        
        let item = CSSearchableItem(uniqueIdentifier: memory.path, domainIdentifier: "br.utfpr.myMemories",
                                    attributeSet: attributeset)
        
        item.expirationDate = Date.distantFuture
        
        CSSearchableIndex.default().indexSearchableItems([item]) {
            error in
            
            if let error = error {
                print("Erro de indexação \(error.localizedDescription)")
            } else {
                print("A memória foi indexada com sucesso!")
            }
        }
        
    }

    static func saveNewMemory(image: UIImage) {
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        let imageName = memoryName + ".jpg"
        let thumbnailName = memoryName + ".thumb"
        do {
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            if let jpegData = UIImageJPEGRepresentation(image, 80) {
                try jpegData.write(to: imagePath, options: [.atomicWrite])
            }
            
            if let thumbnail = ImageHelper.resize(image: image, to: 200) {
                let thumbPath = getDocumentsDirectory().appendingPathComponent(thumbnailName)
                
                if let thumbData = UIImageJPEGRepresentation(thumbnail, 80) {
                    try thumbData.write(to: thumbPath, options: [.atomicWrite])
                }
            }
        } catch {
            print("Falha ao salvar foto no disco")
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

}
