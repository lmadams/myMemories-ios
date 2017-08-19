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

}
