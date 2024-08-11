//
//  WarningTriangle.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 2/8/24.
//

import SwiftUI

/// Warning signal with an optional image inside it. 
///
/// ℹ️ To color it notice that you can tint the stroke with .foreground, the inside with .accentColor and the image with .tint
struct WarningTriangle: View {
    let image: Image?
    
    init(image: Image? = nil) {
        self.image = image
    }
    
    var body: some View {
        GeometryReader { geometry in
            let mandatorySize = min(geometry.size.width, geometry.size.height)
            ZStack {
                Triangle(cornerRadius: mandatorySize*0.08, shouldForceEquilateral: true)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background {
                        Triangle(cornerRadius: mandatorySize*0.08, shouldForceEquilateral: true)
                            .shadow(color: .black.opacity(0.6), radius: 2, x: mandatorySize*0.03)
                    }
                
                Triangle(cornerRadius: mandatorySize*0.03, shouldForceEquilateral: true)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: geometry.size.width*0.75, height: geometry.size.height*0.75)
                    .offset(y: mandatorySize*0.025)
                    .overlay {
                        image?
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.tint)
                            .frame(width: geometry.size.width*0.45, height: geometry.size.height*0.45)
                            .offset(y: mandatorySize*0.12)
                    }
            }
        }
    }
}

#Preview {
    WarningTriangle(image: Image("shout"))
        .accentColor(Color(red: 135/255, green: 199/255, blue: 235/255) )
        .foregroundStyle(.blue)
        .tint(.blue)
        .frame(width: 200, height: 200)
}

