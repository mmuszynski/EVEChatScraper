//
//  ChatLineView.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/21/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import SwiftUI

struct ChatLineView: View {
    var chatLine: ChatLine
    init(_ chatLine: ChatLine) {
        self.chatLine = chatLine
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(chatLine.speaker)
                .bold() +
            Text(" > ") +
            Text(chatLine.content)
            HStack {
                Spacer()
                Text(chatLine.time, format: .dateTime)
                    .font(.caption)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ChatLineView("[ 2025.04.18 17:46:41 ] EVE System > Channel changed to Local : Renyn")
        .padding(10)
}
