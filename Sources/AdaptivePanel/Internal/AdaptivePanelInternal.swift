//
//  AdaptivePanelInternal.swift
//  AdaptivePanel
//
//  Created by yoshiysh on 2023/09/03.
//

import SwiftUI

// MARK: Private Function {
extension AdaptivePanel {
    @MainActor
    func onDismissAnimation() {
        withAnimation(.easeIn) {
            opacity = minOpacity
            isPresentedContnet = false
        }
    }

    @MainActor
    func onEndDismissAnimation() {
        disableAnimations = true
        isPresenteContainer = false
        isPresented = false
        onDismiss?()
    }

    @MainActor
    func fullScreenCoverView() -> some View {
        fullScreenCoverContent()
            .background(BackgroundView(backgroundColor: .clear))
            .onAnimationCompleted(for: opacity) {
                if opacity == minOpacity {
                    onEndDismissAnimation()
                }
            }
            .onAppear {
                disableAnimations = false
                opacity = minOpacity
                isPresentedContnet = false

                withAnimation(.easeIn) {
                    opacity = maxOpacity
                    isPresentedContnet = true
                }
            }
    }

    @MainActor
    func fullScreenCoverContent() -> some View {
        ZStack {
            Color.black.opacity(opacity)
                .ignoresSafeArea()
                .onTapGesture {
                    if barrierDismissible {
                        onDismissAnimation()
                    }
                }
            
            if isPresentedContnet {
                VStack {
                    Spacer()
                        .frame(minHeight: minHeight())
                    
                    panelView()
                        .layoutPriority(1)
                }
                .transition(.move(edge: .bottom).animation(.smooth))
            }
        }
    }

    @MainActor
    func panelView() -> some View {
        content()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangleShape(
                    cornerRadius: 16,
                    corners: [.topLeft, .topRight]
                )
                .fill(Color(UIColor.secondarySystemBackground))
                .ignoresSafeArea()
            )
    }

    @MainActor
    func maxHeight() -> CGFloat {
        UIScreen.main.bounds.height * fraction
    }

    @MainActor
    func minHeight() -> CGFloat {
        UIScreen.main.bounds.height - maxHeight()
    }
}