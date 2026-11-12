import SwiftUI

struct OnboardingView: View {
    /// Wywoływane po naciśnięciu „Zaczynij naukę”.
    var onStart: () -> Void = {}

    @State private var logoVisible = false
    @State private var currentPage = 0
    private let pageCount = 3

    var body: some View {
        VStack(spacing: 0) {
            logo
                .padding(.top, 8)

            Image("img-01")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.top, 20)
                .accessibilityHidden(true)

            Spacer(minLength: 16)

            VStack(spacing: 12) {
                Text("Ucz się angielskiego w kieszeni")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.lingoTextPrimary)
                Text("Krótkie lekcje, fiszki ze zdjęciami, wideo i quizy. Wystarczy 10 minut dziennie.")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.lingoTextSecondary)
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            pageIndicator
                .padding(.top, 24)

            Spacer(minLength: 24)

            VStack(spacing: 12) {
                Button("Zaczynij naukę", action: onStart)
                    .buttonStyle(PrimaryButtonStyle())
                // Logowanie jest poza zakresem projektu – przycisk bez akcji.
                Button("Mam już konto") {}
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lingoBackground.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoVisible = true
            }
        }
    }

    private var logo: some View {
        HStack(spacing: 12) {
            Image(systemName: "bubble.left")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.lingoAccent, in: RoundedRectangle(cornerRadius: 16))
                .accessibilityHidden(true)
            Text("Lingo Pocket")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.lingoTextPrimary)
        }
        .scaleEffect(logoVisible ? 1 : 0.8)
        .opacity(logoVisible ? 1 : 0)
        .accessibilityElement(children: .combine)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.lingoAccent : Color.lingoAccent.opacity(0.15))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Strona \(currentPage + 1) z \(pageCount)")
    }
}

#Preview {
    OnboardingView()
}
