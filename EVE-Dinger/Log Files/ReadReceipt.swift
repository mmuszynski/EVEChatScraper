//
//  ReadReceipt.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/16/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import Foundation

struct ReadReceipt: Codable {
    enum ReceiptError: Error {
        case cannotGetApplicationSupportDirectory
    }
    
    var lastRead: Date?
}
