//
//  MessengerView.swift
//  Multipeer Chat
//
//  Created by Boris Bugor on 03/08/2023.
//

import SwiftUI
import Chat

struct MessengerView: View {
    @EnvironmentObject var model: DeviceFinderViewModel
    
    var body: some View {
        ChatView(messages: model.messages) { message in
            model.send(draft: message)
        }
    }
}
