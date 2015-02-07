//
//  AppDelegate.swift
//  EVE-Dinger
//
//  Created by Mike Muszynski on 2/6/15.
//  Copyright (c) 2015 Mike Muszynski. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate {

    @IBOutlet weak var window: NSWindow!
    var fullContents = ""
    var currentLogFiles = [String: NSURL]()
    var logFiles = [LogFile]()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        loadFiles()
        reloadLogObjects()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationSupportDirectory() -> NSURL? {
        return NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false, error: nil)
    }
    
    func reloadLogObjects() {
        for log in logFiles {
            log.reloadData()
        }
    }
    
    func loadFiles() {
        if let url = applicationSupportDirectory()?.URLByAppendingPathComponent("/EVE Online/p_drive/User/My Documents/EVE/logs/Chatlogs") {
            var fileProperties = [[NSObject : AnyObject]]()
            
            let dateFormat = NSDateFormatter()
            dateFormat.timeZone = NSTimeZone(abbreviation: "GMT")
            dateFormat.dateFormat = "YYYYMMdd"
            let todayString = dateFormat.stringFromDate(NSDate())

            if let files = NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, error: nil) {
                let todaysFiles = files.filter {
                    let url = $0 as NSURL
                    
                    if let path = url.absoluteString {
                        let pathString = NSString(string: path)
                        return pathString.containsString(todayString)
                    }
                    
                    return false
                }
                
                for location in todaysFiles {
                    if let url = location as? NSURL {
                        if let path = url.path {
                            if var properties = NSFileManager.defaultManager().attributesOfItemAtPath(path, error: nil) {
                                if let filename = url.lastPathComponent {
                                    if let logType = filename.componentsSeparatedByString("_").first {
                                        properties["LogType"] = logType
                                        properties["path"] = path
                                    }
                                }
                                fileProperties.append(properties)
                            }
                        }
                    }
                }
                
                
                fileProperties.sort {
                    let date1 = $0[NSFileModificationDate] as NSDate
                    let date2 = $1[NSFileModificationDate] as NSDate
                    return date1.earlierDate(date2) == date1
                }
                
                for properties in fileProperties {
                    let type = properties["LogType"] as String
                    let path = properties["path"] as String
                    
                    currentLogFiles[type] = NSURL(fileURLWithPath: path)
                    
                }
                
                for (name, url) in currentLogFiles {
                    let file = LogFile(url: url, logName: name)
                    logFiles.append(file)
                    file.reloadData()
                }
                
            }

        }
    }
    

}

