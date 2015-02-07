//
//  LogFile.swift
//  EVE-Dinger
//
//  Created by Mike Muszynski on 2/7/15.
//  Copyright (c) 2015 Mike Muszynski. All rights reserved.
//

import Cocoa

class LogFile: NSObject {

    let url : NSURL
    let logName: String
    var data : NSMutableData?
    var dataString : String?
    var lines = [String]()
    
    init(url: NSURL, logName: String) {
        self.url = url
        self.logName = logName
        super.init()
    }
    
    func reloadData() {
        data = NSMutableData(contentsOfURL: url)
        if data != nil {
            dataString = NSString(data: data!, encoding: NSUTF16LittleEndianStringEncoding)
        }
        parse()
    }
    
    func parse() {
        if let newlineSeparated = dataString?.componentsSeparatedByString("\n") {
            lines = newlineSeparated.map {
                var set = NSMutableCharacterSet.whitespaceCharacterSet()
                set.addCharactersInString("\r")
                let components = $0.componentsSeparatedByCharactersInSet(set).filter { !isEmpty($0) }
                return join(" ", components)
            }.filter { !isEmpty($0) }
        }
    }
}