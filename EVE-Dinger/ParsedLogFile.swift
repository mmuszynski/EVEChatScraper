//
//  ParsedLogFile.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 2/14/16.
//  Copyright © 2016 Mike Muszynski. All rights reserved.
//

import Cocoa

class ParsedLogFile: NSObject {
    
    var includedFiles = [NSURL]()
    
    required override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        guard let urls = aDecoder.decodeObjectForKey("includedFileURLS") else {
            return nil
        }
        
        guard urls as? [NSURL] != nil else {
            return nil
        }
        includedFiles = urls as! [NSURL]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(includedFiles, forKey: "includedFileURLS")
    }
    
    func parseFilesInFolderWithURL(url: NSURL) {
        //get files in folder, only text files
        do {
            let files = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles])
            guard files.count == 3 else {
                //refactor: test
                fatalError("Wrong count for directory")
            }
        } catch {
            fatalError("Could not get files in directory, \(error)")
        }
        
        //if file has been parsed, it's in included files
        //parse if not
    }
    
    private func parseIndividualFileWithURL(url: NSURL) {
        
    }
    
}
