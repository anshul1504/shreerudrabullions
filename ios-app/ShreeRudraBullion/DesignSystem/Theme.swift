import SwiftUI

// Same palette as the top of ShreeRudraApp.kt.
extension Color {
    static let gold = Color(hex: 0xB27A13)
    static let dark = Color(hex: 0x111318)
    static let surface = Color(hex: 0xFFFCF5)
    static let softSurface = Color(hex: 0xF6F4EF)
    static let line = Color(hex: 0xE8D8B5)
    static let muted = Color(hex: 0x6F6B62)
    static let textDark = Color(hex: 0x181A20)
    static let buyGreen = Color(hex: 0x006A3A)
    static let sellRed = Color(hex: 0x9E1111)
    static let flashUp = Color(hex: 0x0B8F4D)
    static let flashDown = Color(hex: 0xD62828)

    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum PoppinsWeight {
    case regular, bold, extraBold

    var fontName: String {
        switch self {
        case .regular: "Poppins-Regular"
        case .bold: "Poppins-Bold"
        case .extraBold: "Poppins-ExtraBold"
        }
    }
}

extension Font {
    static func poppins(_ size: CGFloat, _ weight: PoppinsWeight = .regular) -> Font {
        .custom(weight.fontName, size: size, relativeTo: .body)
    }
}
