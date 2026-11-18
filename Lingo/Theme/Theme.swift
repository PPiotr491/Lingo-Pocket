import SwiftUI

extension Color {
    /// Tworzy kolor z wartości szesnastkowej, np. `0x2F5BEA`.
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    static let lingoAccent = Color(hex: 0x2F5BEA)
    static let lingoAccentPressed = Color(hex: 0x2549C7)
    static let lingoAccentSoft = Color(hex: 0xEEF2FD)
    static let lingoTextPrimary = Color(hex: 0x14192B)
    static let lingoTextSecondary = Color(hex: 0x5B6478)
    static let lingoBackground = Color(hex: 0xdceaf2)
    static let lingoSurface = Color.white
    static let lingoAccentText = Color(hex: 0x2549C7)
    /// Seria dni: tło pigułki i tekst (bursztyn).
    static let lingoWarningSoft = Color(hex: 0xFFF4DC)
    static let lingoWarningText = Color(hex: 0x8A5300)
    static let lingoCardShadow = Color(hex: 0x14192B).opacity(0.08)
}

extension View {
    /// Cień karty z makiety (Shadow/Card: 0, 2, blur 12, #14192B 8%).
    func lingoCardShadow() -> some View {
        shadow(color: .lingoCardShadow, radius: 6, x: 0, y: 2)
    }
}

/// Przycisk główny: biały tekst na niebieskim tle.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                configuration.isPressed ? Color.lingoAccentPressed : Color.lingoAccent,
                in: RoundedRectangle(cornerRadius: 16)
            )
    }
}

/// Przycisk drugorzędny: niebieski tekst na jasnoniebieskim tle.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(configuration.isPressed ? Color.lingoAccentPressed : Color.lingoAccent)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Color.lingoAccentSoft, in: RoundedRectangle(cornerRadius: 16))
    }
}
