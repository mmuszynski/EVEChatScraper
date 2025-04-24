//
//  ChatLine.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/21/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import Foundation
import RegexBuilder

struct ChatLine: Identifiable {
    var uuid = UUID()
    var id: UUID { uuid }
    
    var time: Date
    var speaker: String
    var content: String
    
    static let dateFormat = "YYYY.MM.dd HH:mm:ss"
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = dateFormat
        return df
    }()
    
    init?(string: String) {
        //[ 2025.04.18 17:46:41 ] EVE System > Channel changed to Local : Renyn
        let separator = " > "
        let fullRegex = Regex {
            "[ "
            Capture {
                OneOrMore(CharacterClass.any)
            }
            " ] "
            Capture {
                NegativeLookahead {
                    separator
                }
                OneOrMore(CharacterClass.any)
            }
            separator
            Capture {
                ZeroOrMore(CharacterClass.any)
            }
        }

        guard let match = string.wholeMatch(of: fullRegex) else {
            return nil
        }
        
        let time = match.output.1
        let speaker = match.output.2
        let content = "" //match.output.3
        
        if let date = ChatLine.dateFormatter.date(from: String(time)) {
            self.time = date
            self.speaker = String(speaker)
            self.content = String(content)
        } else {
            return nil
        }
    }
}

extension ChatLine: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(string: value)!
    }
}
