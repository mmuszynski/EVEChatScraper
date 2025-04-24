//
//  EVEChatScraperTests.swift
//  EVEChatScraperTests
//
//  Created by Mike Muszynski on 4/21/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import Testing
@testable import EVEChatScraper

struct EVEChatScraperTests {

    @Test func logFileRegex() async throws {
        let text = "[ 2025.04.18 17:46:41 ] EVE System > Channel changed to Local : Renyn"
        #expect(ChatLine(string: text) != nil)
    }
    
    @Test func logFileInitFailures() async throws {
        #expect(ChatLine(string: "﻿[ 2025.04.16 15:34:21 ] Nereid Orion > Good morning  Renyn") != nil)
        #expect(ChatLine(string: "﻿[ 2025.04.16 15:34:23 ] Nereid Orion > https://youtu.be/xi8i08ve4hE?si=6E9nqNsBhAsPDx43") != nil)
        #expect(ChatLine(string: "﻿[ 2025.04.16 15:34:30 ] Tymar Swiftbrook > Morning") != nil)
    }
}
