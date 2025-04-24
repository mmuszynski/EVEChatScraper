//
//  LogFileController.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/17/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import Foundation
import Combine

@MainActor
class LogFileController {
    
    static var shared: LogFileController = .init()
    
    /// Holds the Chat Channel information, which is basically just a named array of url files
    var chatChannels: Set<ChatChannel> = []
    
    /// Adds this file to the list of available files
    /// - Parameter url: The `URL` for the file to register.
    func registerFile(at url: URL, with modificationDate: Date? = nil) throws {
        //Get the file name so that the channel can be deduced
        let filename = url.lastPathComponent
        let channelName = filename.components(separatedBy: "_").first ?? "Unknown"
        
        let logFile = LogFile(url: url, modificationDate: modificationDate ?? .distantPast)
        
        // Add the channel if necessary, or insert the url
        if let channel = chatChannels.first(where: { $0.name == channelName }) {
            channel.files.append(logFile)
        } else {
            let newChannel = ChatChannel()
            newChannel.name = channelName
            newChannel.files = [logFile]
            chatChannels.insert(newChannel)
        }
        
        //let file = try! LogFile(url: url, logName: channelName ?? "unknown")
        //try file.reloadData()
        //logFiles.append(file)
    }
    
    enum DisplayType {
        case today
        case older
        case all
    }
    
    var logFiles: [LogFile] = []
    var displayType: DisplayType = .today
//    var displayedLogFiles: [LogFile] {
//        switch self.displayType {
//        case .today:
//            return logFiles.filter { $0.lastModified.addingTimeInterval(3600 * 24).compare(.now) == .orderedDescending }
//        case .older:
//            return logFiles.filter { $0.lastModified.addingTimeInterval(3600 * 24).compare(.now) == .orderedAscending }
//        case .all:
//            return logFiles
//        }
//    }
    
    var eveLogURL: URL {
        get throws {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let url = documentsURL.appending(path: "EVE/logs/Chatlogs")
            return url
        }
    }
    
    func loadFiles() throws {
        let files = try FileManager.default.contentsOfDirectory(at: eveLogURL, includingPropertiesForKeys: [.contentModificationDateKey, .creationDateKey], options: .skipsHiddenFiles)
            .sorted { first, second in
                let dateFirst = (try? first.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                let dateSecond = (try? second.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                return dateFirst.compare(dateSecond) == .orderedAscending
            }
        
        for fileURL in files {
            try registerFile(at: fileURL)
        }
        
        for channel in chatChannels {
            try channel.loadLatestFile()
        }
        
        NotificationCenter.default.post(name: .refreshOutlineView, object: nil)
    }
}
