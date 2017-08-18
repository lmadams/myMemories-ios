//
//  URLHelper.swift
//  myMemories
//
//  Created by dainf on 18/08/17.
//  Copyright © 2017 br.utfpr. All rights reserved.
//

import UIKit

class URLHelper: NSObject {

    static func audioURL(for memory: URL) -> URL {
        
        return memory.appendingPathExtension("m4a")
    }
    
    static func thumbailURL(for memory: URL) -> URL {
        
        return memory.appendingPathExtension("thumb")
    }
    
    static func transcriptionURL(for memory: URL) -> URL {
        
        return memory.appendingPathExtension("txt")
    }
    
    static func imageURL(for memory: URL) -> URL {
        
        return memory.appendingPathExtension("jpg")
    }
}
