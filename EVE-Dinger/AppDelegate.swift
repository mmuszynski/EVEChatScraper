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

    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var window: NSWindow!
    var fullContents = ""
    var currentLogFiles = [String: NSURL]()
    var logFiles = [LogFile : Int]()
    @IBOutlet var logView: NSTextView!
    
    @IBOutlet weak var notificationButton: NSButton!
    @IBOutlet weak var soundPopUpButton: NSPopUpButton!
    func loadSoundNames() {
        if let url = NSURL(fileURLWithPath: "/System/Library/Sounds") {
            let soundFiles = NSFileManager.defaultManager().contentsOfDirectoryAtURL(url , includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, error: nil) as [NSURL]
            var soundNames = soundFiles.map { $0.lastPathComponent! }
            soundNames = soundNames.map { $0.stringByReplacingOccurrencesOfString(".aiff", withString: "") }
            soundPopUpButton.removeAllItems()
            soundPopUpButton.addItemsWithTitles(["None"] + soundNames)
            
            if let currentSound = NSUserDefaults.standardUserDefaults().valueForKey("alertSound") as? String {
                soundPopUpButton.selectItemWithTitle(currentSound)
            }
        }
        
        
    }
    @IBAction func soundChanged(sender: AnyObject) {
        if let name = soundPopUpButton.titleOfSelectedItem {
            if name != "None" {
                NSUserDefaults.standardUserDefaults().setValue(name, forKey: "alertSound")
                NSSound(named: name)?.play()
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("alertSound")
            }
        }
    }
    @IBAction func notificationButtonChecked(sender: AnyObject) {
        if let button = sender as? NSButton {
            if button.state == NSOnState {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "sendNotifications")
            } else {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "sendNotifications")
            }
        }
        
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        loadSoundNames()
        if NSUserDefaults.standardUserDefaults().boolForKey("sendNotifications") {
            notificationButton.state = NSOnState
        } else {
            notificationButton.state = NSOffState
        }
        
        
        loadFiles()
        reloadLogObjects()
        outlineView.reloadData()
        
        let timer = NSTimer(timeInterval: 1.0, target: self, selector: "reloadLogObjects", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationSupportDirectory() -> NSURL? {
        return NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false, error: nil)
    }
    
    func reloadLogObjects() {
        for log in logFiles.keys.array {
            log.reloadData()
            if logFiles[log] != log.lines.count {
                reloadOutlineViewRowForLog(log)
            }
        }
        
        if outlineView.selectedRow != -1 {
            if let item = outlineView.itemAtRow(outlineView.selectedRow) as? LogFile {
                if item.lines.count != logFiles[item] {
                    loadLogFileIntoDetailView(item)
                }
            }
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
                    logFiles[file] = 0
                    file.reloadData()
                }
                
            }

        }
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil {
            return logFiles.count
        }
        
        return 0
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        return logFiles.keys.array[index]
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let log = item as? LogFile {
            return log
        }
        
        return nil
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        if let log = item as? LogFile {
            let cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as LogFileCellView
            cell.textField?.stringValue = log.logName
            if let readLines = logFiles[log] {
                cell.unreadLines = log.lines.count - readLines
            }
            return cell
        }
        return nil
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return false
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let item = outlineView.selectedRowIndexes.firstIndex
        let selectedItem = outlineView.itemAtRow(item) as LogFile
        loadLogFileIntoDetailView(selectedItem)
    }
    
    func loadLogFileIntoDetailView(log: LogFile) {
        let logText = "\n".join(log.lines)
        logView.string = logText
        logFiles[log] = log.lines.count
        reloadOutlineViewRowForLog(log)
        logView.scrollToEndOfDocument(self)
    }
    
    func reloadOutlineViewRowForLog(log: LogFile) {
        let rows = NSIndexSet(index: outlineView.rowForItem(log))
        outlineView.reloadDataForRowIndexes(rows, columnIndexes: NSIndexSet(index: 0))
    }
    

}

