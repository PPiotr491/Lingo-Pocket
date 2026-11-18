import SwiftUI

/// Ekran główny aplikacji (po onboardingu).
struct HomeView: View {
    // TODO - podmienić na prawdziwe dane użytkownika
    var username: String = "Username"
    var streakDays: Int = 0
    var categories: [CategoryView] = CategoryView.samples

    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                continueCard
                categoriesSection
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

            streakBadge
        }
    }

    /// Pigułka „Seria dni”: płomień + licznik na bursztynowym tle.
    private var streakBadge: some View {
        HStack(spacing: 8) {
            Image("icon-flame")
                .resizable()
                .scaledToFit()
                .frame(width: 8.67, height: 13)
                .frame(width: 20, height: 20)
                .accessibilityHidden(true)
            Text("\(streakDays) dni")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.lingoWarningText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.lingoWarningSoft, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Seria: \(streakDays) dni")
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kategorie")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.lingoTextPrimary)

            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(categories) { category in
                    NavigationLink(value: ContentView.Route.lessons(category)) {
                        CategoryTile(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
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

/// Kafelek kategorii: zdjęcie + nazwa + liczba lekcji.
struct CategoryTile: View {
    let category: CategoryView

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .frame(height: 112)
                .overlay(
                    Image(category.imageName)
                        .resizable()
                        .scaledToFill()
                )
                .clipped()
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.lingoTextPrimary)
                Text(category.lessonCountText)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.lingoTextSecondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.lingoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .lingoCardShadow()
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    NavigationStack {
        HomeView(streakDays: 7)
            .navigationDestination(for: ContentView.Route.self) { route in
                if case .lessons(let category) = route {
                    LessonListView(category: category)
                }
            }
    }
}
