//
//  OvderCurrentContextRepresentable.swift
//  AdaptiveModal
//
//  Created by yoshiysh on 2023/10/02.
//

import SwiftUI

struct OvderCurrentContextRepresentable<Content: View>: UIViewControllerRepresentable {
    @Binding private var isPresented: Bool
    private let willDismiss: () -> Void
    private let onDismiss: () -> Void
    private let content: () -> Content

    init(
        isPresented: Binding<Bool>,
        willDismiss: @escaping () -> Void,
        onDismiss: @escaping () -> Void,
        content: @escaping () -> Content
    ) {
        _isPresented = isPresented
        self.willDismiss = willDismiss
        self.onDismiss = onDismiss
        self.content = content
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        UIViewController()
    }

    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {
        let isHostingControllerPresented = uiViewController.presentedViewController is UIHostingController<Content>

        if isPresented {
            if isHostingControllerPresented { return }

            let hostingController = HostingController(rootView: content())
            hostingController.presentationController?.delegate = context.coordinator
            DispatchQueue.main.async {
                uiViewController.present(hostingController, animated: false)
            }
        } else {
            if !isHostingControllerPresented { return }

            DispatchQueue.main.async {
                uiViewController.dismiss(animated: false) {
                    onDismiss()
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        private let parent: OvderCurrentContextRepresentable

        init(parent: OvderCurrentContextRepresentable) {
            self.parent = parent
        }

        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            parent.willDismiss()
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.onDismiss()
        }
    }

    // MARK: - UIHostingController
    class HostingController: UIHostingController<Content> {
        override init(rootView: Content) {
            super.init(rootView: rootView)
            modalPresentationStyle = .overCurrentContext
            view.backgroundColor = .clear
        }
        
        @MainActor 
        required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}