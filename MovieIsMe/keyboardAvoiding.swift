//
//  File.swift
//  MovieIsMe
//
//  Created by lujin mohammed on 30/07/1446 AH.
//

import Foundation
import SwiftUI

struct KeyboardAvoidingModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        withAnimation {
                            self.keyboardHeight = keyboardFrame.height - 50
                        }
                    }
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    withAnimation {
                        self.keyboardHeight = 0
                    }
                }
            }
    }
}

extension View {
    func keyboardAvoiding() -> some View {
        self.modifier(KeyboardAvoidingModifier())
    }
}
