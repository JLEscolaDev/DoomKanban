//
//  SwiftUIView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 6/8/24.
//

import SwiftUI

struct CircularLoaderBackground<Content: View>: View {
    @Environment(\.shadowOffset) var shadowOffset
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Circle background
                backgroundCircle(geometry: geometry)
                
                // Content in the middle
                content()
                
                // Circular stroke
                strokeLayer(geometry: geometry)
            }.padding(geometry.size.height*0.1)
        }
    }
}

// - MARK: Subviews
extension CircularLoaderBackground {
    private func backgroundCircle(geometry: GeometryProxy) -> some View {
        Circle()
            .fill(Color.backgroundLightGray)
            .shadow(color: .black.opacity(0.7), radius: 2,x: shadowOffset.x, y: shadowOffset.y + (geometry.size.height * 0.1))
    }
    
    private func strokeLayer(geometry: GeometryProxy) -> some View {
        let minSize = min(geometry.size.width, geometry.size.height)
        return Circle()
            .strokeBorder(Color.black, lineWidth: minSize * 0.04)
    }
}

#Preview {
    CircularLoaderBackground {
        Text("T").bold().font(.system(size: 300))
    }.frame(width: 500, height: 500)
}

