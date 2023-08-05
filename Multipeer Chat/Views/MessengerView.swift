//
//  MessengerView.swift
//  Multipeer Chat
//
//  Created by Boris Bugor on 03/08/2023.
//

import SwiftUI
import SwiftyChat

struct MessengerView: View {
    @EnvironmentObject var model: DeviceFinderViewModel
    @State var message: String = ""
    @State var isEditing: Bool = false
    
    var inputBarView: some View {
        BasicInputView(
            message: $message,
            isEditing: $isEditing,
            placeholder: "Type something",
            onCommit: { messageKind in
                self.model.send(draft: messageKind)
            }
        )
        .padding(8)
        .padding(.bottom, 50)
        .background(Color.primary.colorInvert())
        .eraseToAnyView()
    }

    
    var body: some View {
        ChatView<MockMessages.ChatMessageItem, MockMessages.ChatUserItem>(messages: $model.messages) {
            inputBarView.eraseToAnyView()
        }
        .environmentObject(
            ChatMessageCellStyle()
        )
    }
}
