//
//  DraggableKanbanCard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 16/8/24.
//

import SwiftUI

struct DraggableKanbanCard: View {
    let task: KanbanTask
    let geometry: GeometryProxy
    @Binding var cardDragStatus: KanbanColumn.DragStatus
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    let onDrag: (DragGesture.Value) -> Void
    let onEnded: (DragGesture.Value) -> Void
    
    @State private var progress: Double = 0.0
    @Environment(\.openWindow) private var openWindow
    @Environment(\.mobileChatVisibility) private var isChatVisible
    

    var body: some View {
        let cardHeight = geometry.size.height * 0.13
        
        return KanbanCard(task: task)
            .hoverEffect { effect, isActive, proxy in
                effect.scaleEffect(isActive ? 0.9 : 1.0)
            }
            .background(
                // Animated gradient stroke that will be always on the back of the view and will show resizing the card to 0.9 scale on hover.
                AnimatedGradientStrokeView(progress: progress, lineWidth: (cardHeight)*0.2)
                    .drawingGroup() // ⚠️ This is mandatory. Without this drawingGroup, the performance will spike up to 80%
            )
            .frame(depth: isDragging ? 30 : 4)
            // Dinamic shadow that will change when dragging for depth feeling
            .shadow(color: .black.opacity(isDragging ? 0.7 : 0.1), radius: isDragging ? 12 : 18, x: 0, y: isDragging ? geometry.size.height * 0.03 : geometry.size.height * 0.005)
            .frame(height: cardHeight)
            .overlay(
                // Create a small indicator on the top right corner replicating an advanced behaviour of the new draggable modifier (we use onDrag because it is more open to personalization, we are not forced to long press to drag the views and things like that)
                topRightDragAvailabilityIndicator
            )
            // Key part for moving the card
            .offset(dragOffset)
            // We make slightly bigger the card so we feel we are bringing it close to us (this is used for the same purpose as frame(depth)
            .scaleEffect(isDragging ? 1.2 : 1)
            .gesture(
                dragCardGesture
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        if isChatVisible.wrappedValue.0 != .visible, task.isFlagged {
                            isChatVisible.wrappedValue = (.visible, task)
                        }
                    }
            )
            // zIndex will ensure the card be dragged over all the other views
            .zIndex(isDragging ? 1 : 0)
            .onAppear() {
                startBackgroundStrokeAnimation()
            }
    }
    
    var topRightDragAvailabilityIndicator: some View {
        let kanbanCardWidth = geometry.size.width * 0.21
        return Group {
            if cardDragStatus == .notAllowed && isDragging {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            } else if cardDragStatus == .valid && isDragging {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .font(.largeTitle)
        .padding()
        .position(x: (kanbanCardWidth*0.9)-3)
    }
    
    var dragCardGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
        DragGesture()
            .onChanged { value in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isDragging = true
                }
                dragOffset = value.translation
                onDrag(value)
            }
            .onEnded { value in
                isDragging = false
                dragOffset = .zero
                onEnded(value)
            }
    }
    
    private func startBackgroundStrokeAnimation() {
        withAnimation(
            .linear(duration: 1.5)
            .repeatForever(autoreverses: false)
        ) {
            progress = 1.0
        }
    }
}



