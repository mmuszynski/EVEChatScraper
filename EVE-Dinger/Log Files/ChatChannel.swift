//
//  Channel.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/17/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import Foundation
import RegexBuilder

class ChatChannel {
    var name: String = "Unknown"
    var files: Array<LogFile> = []
    
    var monitor: LogFileMonitor?
    
    var lines: [ChatLine] = []
    var loadedFileRange: Range<Array<LogFile>.Index>?
    
    func loadFiles(in range: Range<Array<LogFile>.Index>) throws {
        for file in files[range] {
            let strings = try String(contentsOf: file.url).components(separatedBy: .newlines)
            let lines = strings.compactMap(ChatLine.init)
            self.lines.append(contentsOf: lines)
        }
    }
    
    func loadLatestFile() throws {
        try self.loadFiles(in: 0..<1)
    }
}

extension ChatChannel: Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func ==(lhs: ChatChannel, rhs: ChatChannel) -> Bool {
        return lhs.name == rhs.name
    }
}
