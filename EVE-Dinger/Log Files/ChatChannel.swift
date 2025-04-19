//
//  Channel.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/17/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import Foundation

class ChatChannel {
    var name: String = "Unknown"
    var files: Array<LogFile> = []
    
    var monitor: LogFileMonitor?
}

extension ChatChannel: Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func ==(lhs: ChatChannel, rhs: ChatChannel) -> Bool {
        return lhs.name == rhs.name
    }
}
