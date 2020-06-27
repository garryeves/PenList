////
////  KeyboardHeightPublisher.swift
////  KeyboardAvoidanceSwiftUI
////
////  Created by Vadim Bulavin on 3/27/20.
////  Copyright © 2020 Vadim Bulavin. All rights reserved.
////
//
//import Foundation
//import Combine
//import UIKit
//import SwiftUI
//
//extension Publishers {
//    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
//        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
//            .map { $0.keyboardHeight }
//
//        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
//            .map { _ in CGFloat(0) }
//
//        return MergeMany(willShow, willHide)
//            .eraseToAnyPublisher()
//    }
//}
//
//extension Notification {
//    var keyboardHeight: CGFloat {
//        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
//    }
//}
//
//// From https://stackoverflow.com/a/14135456/6870041
//extension UIResponder {
//    static var currentFirstResponder: UIResponder? {
//        _currentFirstResponder = nil
//        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
//        return _currentFirstResponder
//    }
//
//    private static weak var _currentFirstResponder: UIResponder?
//
//    @objc private func findFirstResponder(_ sender: Any) {
//        UIResponder._currentFirstResponder = self
//    }
//
//    var globalFrame: CGRect? {
//        guard let view = self as? UIView else { return nil }
//        return view.superview?.convert(view.frame, to: nil)
//    }
//}
//
//struct KeyboardAdaptive: ViewModifier {
//    @State private var bottomPadding: CGFloat = 0
//
//    func body(content: Content) -> some View {
//        GeometryReader { geometry in
//            content
//                .padding(.bottom, self.bottomPadding)
//                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
//                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
//                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
//                    self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom)
//            }
//            .animation(.easeOut(duration: 0.16))
//        }
//    }
//}
//
//extension View {
//    func keyboardAdaptive() -> some View {
//        ModifiedContent(content: self, modifier: KeyboardAdaptive())
//    }
//}

import Foundation
import SwiftUI

final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published var readyToAppear = false
    var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
        readyToAppear = true
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
        readyToAppear = false
    }

}
