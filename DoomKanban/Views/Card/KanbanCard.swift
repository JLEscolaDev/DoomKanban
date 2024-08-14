//
//  KanbanCard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct KanbanTask: Transferable, Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let title: String
    let color: Color
    let value: Int
    let isWarningEnabled: Bool
    let isFlagged: Bool
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .kanbanTask)
    }
    
    static func ==(lhs: KanbanTask, rhs: KanbanTask) -> Bool {
        return lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, color, value, isWarningEnabled, isFlagged
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(value, forKey: .value)
        try container.encode(isWarningEnabled, forKey: .isWarningEnabled)
        try container.encode(isFlagged, forKey: .isFlagged)
        
        let colorHex = UIColor(color).toHexString()
        try container.encode(colorHex, forKey: .color)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        value = try container.decode(Int.self, forKey: .value)
        isWarningEnabled = try container.decode(Bool.self, forKey: .isWarningEnabled)
        isFlagged = try container.decode(Bool.self, forKey: .isFlagged)
        
        let colorHex = try container.decode(String.self, forKey: .color)
        color = Color(hex: colorHex)
    }
    
    init(
        title: String,
        color: Color,
        value: Int,
        isWarningEnabled: Bool = false,
        isFlagged: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.color = color
        self.value = value
        self.isWarningEnabled = isWarningEnabled
        self.isFlagged = isFlagged
    }
}

extension UTType {
    static let kanbanTask = UTType(exportedAs: "jle.developement.DoomKanban.KanbanTask")
}

/// Simple card with a Kanban board task style (colored top, value, flag and warning)
///
/// - WARNING: ⚠️ This card is not prepared to work for a height bigger than width.
struct KanbanCard: View {
    let task: KanbanTask
    
    var body: some View {
        GeometryReader { geometry in
            let padding = geometry.size.width*0.03
            let cardInsideHeight = geometry.size.height*0.74
            VStack(spacing: 0) {
                title(geometry: geometry)
                
                cardContent(
                    padding: padding,
                    cardInnerHeight: cardInsideHeight,
                    geometry: geometry
                )
            }.shadow(color: .black.opacity(0), radius: 0) // This avoids card content to also have shadow if we set it on the parent
            .background(
                task.color
            )
            
        }
    }
}

// - MARK: Subviews
extension KanbanCard {
    
    // - MARK: Title
    /// Text used as title inside the top header of the card
    private func title(
        geometry: GeometryProxy
    ) -> some View {
        HStack {
            Text(task.title)
                .lineLimit(1)
                .font(.system(size: geometry.size.height*0.4))
                .padding(.horizontal, geometry.size.width*0.03)
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
        Text("\(task.value)")
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
            title: "Esto es un texto de prueba para ajustar todo",
            color: .blue,
            value: 3
        )).frame(width: 150, height: 100)
        KanbanCard(task: .init(
            title: "Esto es un texto de prueba para ajustar todo",
            color: .blue,
            value: 7,
            isFlagged: true
        )).frame(width: 150, height: 100)
        KanbanCard(task: .init(
            title: "Esto es un texto de prueba para ajustar todo",
            color: .blue,
            value: 5,
            isWarningEnabled: true
        )).frame(width: 150, height: 100)
        KanbanCard(task: .init(
            title: "Esto es un texto de prueba para ajustar todo",
            color: .blue,
            value: 13,
            isWarningEnabled: true,
            isFlagged: true
        )).frame(width: 150, height: 100)
    }
}
