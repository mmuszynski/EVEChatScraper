//
//  ChatLineListView.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/22/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import SwiftUI

struct ChatLineListView: View {
    var chatLines: [ChatLine]
    init(_ chatLines: [ChatLine]) {
        self.chatLines = chatLines
    }
    
    var body: some View {
        List(chatLines) { line in
            ChatLineView(line)
        }
    }
}

#Preview {
    ChatLineListView([
        "[ 2025.04.16 15:33:09 ] EVE System > Channel changed to Local : Renyn",
        "﻿[ 2025.04.16 15:34:21 ] Nereid Orion > Good morning  Renyn",
        "﻿[ 2025.04.16 15:34:23 ] Nereid Orion > https://youtu.be/xi8i08ve4hE?si=6E9nqNsBhAsPDx43",
        "﻿[ 2025.04.16 15:34:30 ] Tymar Swiftbrook > Morning",
        "[ 2025.04.16 15:37:16 ] Nereid Orion > =^^=",
        "[ 2025.04.16 15:37:20 ] nokillme123 > HyperNet offer: Ark HyperNet offer: Nomad HyperNet offer: Revelation Navy Issue",
        "[ 2025.04.16 15:37:31 ] Arkhatan TheGods > me in offer?",
        "[ 2025.04.16 15:37:33 ] Arkhatan TheGods > nah",
        "[ 2025.04.16 15:55:29 ] Nereid Orion > https://youtu.be/WJm9T1wPIns?si=EmuPn2lhpov05JaD"
    ])
}
