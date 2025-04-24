//
//  LogFile.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/18/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import Foundation

struct LogFile: Equatable, Hashable {
    var url: URL
    var modificationDate: Date = .distantPast
    
    var name: String { url.lastPathComponent.components(separatedBy: "_").first ?? "Unknown" }
    var lastLine: String { "" }
    var hasUpdates: Bool = false
    
    mutating func updateModificationDate() {
        self.modificationDate = self.url.getMetadata()?["kMDItemContentModificationDate"] as? Date ?? .distantPast
    }
}
