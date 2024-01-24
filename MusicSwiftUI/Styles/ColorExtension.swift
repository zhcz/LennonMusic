//
//  ColorExtension.swift
//  ColorExtension
//
//  Created by zhanghao on 2024/1/8.
//

import SwiftUI

extension Color {
    
    static let primary_color = Color("EFF0F9_282C31")
    static let main_color = Color(hex: "657592")
    static let main_white = Color("657592_F4F4F4")
    
    static let text_header = Color("333333_F4F4F4")
    static let text_primary = Color("657592_C6CBDA")
    static let text_primary_f1 = Color.text_primary.opacity(0.8)
    
    static let disc_line = Color("666666_F4F4F4")
    
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
