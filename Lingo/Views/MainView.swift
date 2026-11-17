import SwiftUI

/// Ekran główny aplikacji (po onboardingu).
struct MainView: View {
    // TODO - podmienić na prawdziwe dane użytkownika
    var username: String = "Username"
    var streakDays: Int = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                continueCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lingoBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Cześć, **\(username)**")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.lingoTextPrimary)
                Text("Kontynuuj naukę języka")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.lingoTextSecondary)
            }

            Spacer(minLength: 8)

            HStack(spacing: 4) {
                Image("streakImg")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .accessibilityHidden(true)
                Text("\(streakDays) dni")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.lingoTextPrimary)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var continueCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dzisiejsza lekcja")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.lingoTextPrimary)
            Text("Krótka lekcja zajmie około 10 minut.")
                .font(.system(size: 15))
                .foregroundStyle(Color.lingoTextSecondary)
            // Akcja zostanie podpięta, gdy powstanie ekran lekcji.
            Button("Kontynuuj") {}
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lingoAccentSoft, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
}
