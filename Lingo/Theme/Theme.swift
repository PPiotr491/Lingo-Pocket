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
    static let lingoBackground = Color(hex: 0xF5F7FC)
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
