//
//  LogFile.swift
//  EVE-Dinger
//
//  Created by Mike Muszynski on 2/7/15.
//  Copyright (c) 2015 Mike Muszynski. All rights reserved.
//

import Cocoa
import UserNotifications

extension Notification.Name {
    static let logUpdated = Notification.Name("com.mmuszynski.EVEChatScraper.logUpdated")
}

extension URL {
    func getMetadata() -> [String:Any]? {
        guard let mditem = MDItemCreateWithURL(nil, self as CFURL) else {
            print("Can't get MDItem for \(self)")
            return nil
        }
        
        guard let mdnames = MDItemCopyAttributeNames(mditem) else {
            print("Can't get MDItemAttributeNames for \(self)")
            return nil
        }
        
        guard let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] else {
            print("Can't get MDItemAttributes for \(self)")
            return nil
        }
     
        return mdattrs
    }
}

class LogFileMonitor: NSObject {
    
    /// The URL that points to the file
    let url : URL
    
    /// The FileHandle used to describe the file to the operating system
    let fileHandle: FileHandle
    
    /// The object that monitors for changes in the FileSystem
    let source: DispatchSourceFileSystemObject
    
    let encoding: String.Encoding = .utf16
    
    var dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
    var lastModified: Date = .distantPast
    var createdAt: Date = .distantPast
    
    let logName: String
    var logString : String?
    var lines = [String]()
    
    var lastLine: String {
        lines.last ?? "Empty"
    }
    
    var lastReadAt: Date = .distantPast
    
    var hasUpdates: Bool {
        lastModified.compare(lastReadAt) == .orderedAscending
    }
    
    var receiptURL: URL {
        get throws {
            guard let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw ReadReceipt.ReceiptError.cannotGetApplicationSupportDirectory
            }
            let url = support.appending(path: "com.mmuszynski.EVEChatScraper/", directoryHint: .isDirectory)
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            let name = self.url.lastPathComponent
            return url.appending(path: "\(name).json", directoryHint: .notDirectory)
        }
    }
    
    init(url: URL, logName: String) throws {
        self.url = url
        self.logName = logName
        
        self.fileHandle = try FileHandle(forReadingFrom: url)
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileHandle.fileDescriptor,
                                                                eventMask: .all,
                                                                queue: .main)
        
        super.init()
        
        self.source.setEventHandler {
            let event = self.source.data
            self.process(event)
        }
        
        self.source.setCancelHandler {
            try? self.fileHandle.close()
        }
        
        self.source.activate()
        self.getReadReceipt()
    }
    
    deinit {
        source.cancel()
    }
    
    
    /// Called when the filesystem detects an event. For EVE logs, this turns out to be .extend and .write
    /// - Parameter event: The `FileSystemEvent` that triggered the update
    func process(_ event: DispatchSource.FileSystemEvent) {
        print("\(self.logName) detected event with code \(event.description)")
        
        do {
            if let newData = try self.fileHandle.readToEnd(),
               let string = String(data: newData, encoding: self.encoding) {
                print("Log \(logName) got string: \(string)")
                let newLines = string.components(separatedBy: .newlines).filter { $0 != "" }
                self.lines.append(contentsOf: newLines)
                
                lastModified = Date()
                
                NotificationCenter.default.post(name: .logUpdated, object: self)
            }
        } catch {
            print("Could not get new data with \(error)")
        }
    }
    
    func reloadData() throws {
        self.loadFileDates()
        if let data = try fileHandle.readToEnd() {
            logString = String(data: data, encoding: self.encoding)
            try parse()
        }
    }
    
    func loadFileDates() {
        let mdattrs = self.url.getMetadata()
        
        if let modificationDateString = mdattrs?["kMDItemContentModificationDate"] as? Date {
            self.lastModified = modificationDateString
        }
        
        if let creationDateString = mdattrs?["kMDItemContentCreationDate"] as? Date {
            self.createdAt = creationDateString
        }
    }
    
    func parse() throws {
        let lines = logString?.components(separatedBy: .newlines).filter { !$0.isEmpty }
        self.lines = lines ?? []
    }
    
    func setRead() throws {
        lastReadAt = Date()
        let encoder = JSONEncoder()
        let data = try encoder.encode(self.lastReadAt)
        try data.write(to: self.receiptURL)
    }
    
    func getReadReceipt() {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: self.receiptURL) else { return }
        self.lastReadAt = (try? decoder.decode(Date.self, from: data)) ?? .distantPast
    }
    
}

extension DispatchSource.FileSystemEvent: @retroactive CustomStringConvertible {
    public var description: String {
        switch self.rawValue {
        case 1:
            return "delete"
        case 2:
            return "write"
        case 4:
            return "extend"
        case 8:
            return "attrib"
        case 16:
            return "link"
        case 32:
            return "rename(move)"
        case 64:
            return "revoke"
        case 128:
            return "funlock"
        case 256:
            return "all"
        default:
            return "#\(self.rawValue) \(self.options) "
        }
    }
    
    /// Returns all included option elements as an array of single events
    public var options: [DispatchSource.FileSystemEvent] {
        var array: [DispatchSource.FileSystemEvent] = []
        
        if self.contains(.delete) { array.append(.delete) }
        if self.contains(.write) { array.append(.write) }
        if self.contains(.extend) { array.append(.extend) }
        if self.contains(.attrib) { array.append(.attrib) }
        if self.contains(.funlock) { array.append(.funlock) }
        if self.contains(.rename) { array.append(.rename) }
        if self.contains(.revoke) { array.append(.revoke) }
        if self.contains(.link) { array.append(.link) }
        if self.contains(.all) { array.append(.all) }
        
        return array
    }
}
