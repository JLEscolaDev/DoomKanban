//
//  KanbanCard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI

/// Simple card with a Kanban board task style (colored top, value, flag and warning)
///
/// - WARNING: ⚠️ This card is not prepared to work for a height bigger than width.
struct KanbanCard: View {
    let task: KanbanTask
    @Environment(KanbanAppVM.self) var kanbanAppVM
    
    var body: some View {
        GeometryReader { geometry in
            let padding = geometry.size.width*0.03
            let cardInsideHeight = geometry.size.height*0.74
            VStack(spacing: 0) {
                header(geometry: geometry)
                
                cardContent(
                    padding: padding,
                    cardInnerHeight: cardInsideHeight,
                    geometry: geometry
                )
            }.shadow(color: .black.opacity(0), radius: 0) // This avoids card content to also have shadow if we set it on the parent
            .background(
                task.color
            )
            .onChange(of: task.isComplete) { oldValue, newValue in
                if newValue {
                    kanbanAppVM.points += calculatePoints()
                }
            }
        }
    }
    
    private func calculatePoints() -> Int {
        let basePoints = 100
        var addPoints = basePoints
        if task.isWarningEnabled {
            addPoints *= 2
        }
        if kanbanAppVM.wardenIsWatching {
            addPoints *= 2
        }
        return addPoints
    }
}

// - MARK: Subviews
extension KanbanCard {
    
    // - MARK: Header
    /// Title and check indicator
    private func header(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            title(geometry: geometry)
            if task.isComplete {
                Image(systemName: "checkmark.square.fill")
                    .resizable()
                    .frame(width: geometry.size.height*0.15, height: geometry.size.height*0.15)
                    .padding(.trailing, geometry.size.width*0.03)
            }
        }
    }
    
    // - MARK: Title
    /// Text used as title inside the top header of the card
    private func title(
        geometry: GeometryProxy
    ) -> some View {
        HStack {
            Text(task.title)
                .lineLimit(1)
                .font(.system(size: geometry.size.height*0.4))
                .padding(.leading, geometry.size.width*0.05)
                .padding(.vertical, geometry.size.width*0.05)
                .minimumScaleFactor(0.2)
                .frame(height: geometry.size.height*0.25)
            Spacer()
        }
    }
    
    /// All the card content that is not related to the header
    private func cardContent(
        padding: CGFloat,
        cardInnerHeight: CGFloat,
        geometry: GeometryProxy
    ) -> some View {
        Group {
            let fontSize = (cardInnerHeight*0.8-(padding*2))
            cardValue(with: .system(size: fontSize))
                .padding(padding)
                .frame(width: geometry.size.width, height: geometry.size.height*0.75)
                .background(.white)
                .overlay {
                    HStack {
                        if task.isFlagged {
                            flag(for: geometry)
                        }
                        Spacer()
                        if task.isWarningEnabled {
                            warning(for: geometry)
                        }
                    }
                    .padding(padding)
                    .frame(width: geometry.size.width, height: geometry.size.height*0.75)
                }
        }
    }
    
    // - MARK: Flag
    /// Simple red flag drawn with bezier paths using ``RedFlag`` view
    private func flag(for geometry: GeometryProxy) -> some View {
        VStack {
            RedFlag()
                .fill(.red)
                .frame(
                    width: geometry.size.width*0.15,
                    height: geometry.size.height*0.3
                )
            Spacer()
        }
    }
    
    // - MARK: Card Value
    /// Numeric value that will be displayed on the center of the card
    private func cardValue(with font: Font) -> some View {
        let value: String = {
                switch task.value {
                case 1...:
                    "\(task.value)"
                case 0:
                    "✅"
                default:
                    "❌"
                }
            }()
        return Text("\(value)")
            .lineLimit(1, reservesSpace: true)
            .font(font)
            .minimumScaleFactor(0.01)
            .foregroundStyle(.black)
            .bold()
    }
    
    // - MARK: Warning
    /// Red exclamation mark displayed on the right of the card
    private func warning(for geometry: GeometryProxy) -> some View {
        Text("!")
            .foregroundStyle(.red)
            .font(.system(size: geometry.size.height*0.4))
            .minimumScaleFactor(0.2)
            .foregroundStyle(.black)
            .bold().aspectRatio(contentMode: .fit)
            .padding(.trailing, geometry.size.width*0.1)
    }
}

// - MARK: PREVIEW
#Preview {
    VStack(spacing: 20) {
        KanbanCard(task: .init(
            projectId: 1,
            sprintId: 1,
            title: "Esto es un texto de prueba para ajustar todo",
            color: .blue,
            value: 3,
            isComplete: true
        )).frame(width: 150, height: 100)
        KanbanCard(task: .init(
            projectId: 1,
            sprintId: 2,
            title: "Esto es un texto de prueba para ajustar todo",
            color: .blue,
            value: 7,
            isFlagged: true
        )).frame(width: 150, height: 100)
        KanbanCard(task: .init(
            projectId: 2,
            sprintId: 1,
            title: "Esto es un texto de prueba para ajustar todo",
            color: .blue,
            value: 5,
            isWarningEnabled: true
        )).frame(width: 150, height: 100)
        KanbanCard(task: .init(
            projectId: 2,
            sprintId: 3,
            title: "Esto es un texto de prueba para ajustar todo",
            color: .blue,
            value: 13,
            isWarningEnabled: true,
            isFlagged: true
        )).frame(width: 150, height: 100)
    }
}
