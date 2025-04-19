//
//  AppDelegate.swift
//  EVE-Dinger
//
//  Created by Mike Muszynski on 2/6/15.
//  Copyright (c) 2015 Mike Muszynski. All rights reserved.
//

import Cocoa
import Combine

extension FileAttributeKey {
    static let eveOnlineChatChannelName = FileAttributeKey("eveOnlineChatChannelName")
    static let path = FileAttributeKey("path")
    static let url = FileAttributeKey("url")
}

@main
@MainActor class AppDelegate: NSObject, NSApplicationDelegate {
    
    var controller = LogFileController()
    
    @IBOutlet weak var notificationButton: NSButton!
    @IBOutlet weak var soundPopUpButton: NSPopUpButton!
    func loadSoundNames() {
        var soundNames: [String]?
        
        let url = URL(fileURLWithPath: "/System/Library/Sounds")
        if let soundFiles = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            soundNames = soundFiles.map(\.lastPathComponent)
            soundNames = soundNames?.map { $0.replacingOccurrences(of: ".aiff", with: "") }
        }
        
        soundPopUpButton.removeAllItems()
        soundPopUpButton.addItems(withTitles: ["None"] + (soundNames ?? []))
        
        if let currentSound = UserDefaults.standard.string(forKey: "alertSound") {
            soundPopUpButton.selectItem(withTitle: currentSound)
        }
    }
    
    @IBAction func soundChanged(sender: AnyObject) {
        if let name = soundPopUpButton.titleOfSelectedItem {
            if name != "None" {
                UserDefaults.standard.set(name, forKey: "alertSound")
                NSSound(named: name)?.play()
            } else {
                UserDefaults.standard.removeObject(forKey: "alertSound")
            }
        }
    }
    @IBAction func notificationButtonChecked(sender: AnyObject) {
        if let button = sender as? NSButton {
            UserDefaults.standard.set(button.state == .on, forKey: "sendNotifications")
        }
        
    }
    
    private var cancellable : AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Insert code here to initialize your application
        loadSoundNames()
        notificationButton.state = UserDefaults.standard.bool(forKey: "sendNotifications") ? .on : .off
        

    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportDirectory() -> URL? {
        try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    
    
    @IBAction func rescanButtonPressed(sender: AnyObject) {
        controller.logFiles.removeAll()
        try! controller.loadFiles()
    }
    
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    @IBAction func segmentedControlValueChanged(_ sender: AnyObject) {
        switch segmentedControl.selectedSegment {
        case 0:
            controller.displayType = .today
        case 1:
            controller.displayType = .older
        default:
            controller.displayType = .all
        }
    }
}

