//
//  Color+Hex.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 6/8/24.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    func toHexString() -> String {
        let components = cgColor.components
        let r = Float((components?[0] ?? 0) * 255.0)
        let g = Float((components?[1] ?? 0) * 255.0)
        let b = Float((components?[2] ?? 0) * 255.0)
        return String(format: "%02lX%02lX%02lX", lroundf(r), lroundf(g), lroundf(b))
    }
}


extension Color {
    func darker(by percentage: CGFloat = 0.2) -> Color {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    func adjust(by percentage: CGFloat = 0.2) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        
        return Color(
            red: min(red + percentage, 1.0),
            green: min(green + percentage, 1.0),
            blue: min(blue + percentage, 1.0),
            opacity: opacity
        )
    }
}

