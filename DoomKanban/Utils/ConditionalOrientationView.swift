//
//  ConditionalOrientationView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 6/8/24.
//

import SwiftUI

enum Orientation {
    case vertical
    case horizontal
}

struct ConditionalOrientationView<Content: View>: View {
    var orientation: Orientation = .horizontal
    var content: () -> Content
    
    var body: some View {
        switch orientation {
            case .vertical:
                VStack {
                    content()
                }
            case .horizontal:
                HStack {
                    content()
                }
        }
        
    }
}
