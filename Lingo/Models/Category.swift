import Foundation

/// Kategoria tematyczna lekcji (np. Jedzenie).
struct CategoryView: Identifiable, Hashable {
    let id: String
    let name: String
    let imageName: String
    let lessonCount: Int

    /// Odmiana: „1 lekcja”, „2–4 lekcje”, „5+ lekcji” (z wyjątkiem 12–14).
    var lessonCountText: String {
        let lastDigit = lessonCount % 10
        let lastTwo = lessonCount % 100
        if lessonCount == 1 { return "1 lekcja" }
        if (2...4).contains(lastDigit) && !(12...14).contains(lastTwo) {
            return "\(lessonCount) lekcje"
        }
        return "\(lessonCount) lekcji"
    }
}

extension CategoryView {
    // TODO - pozostałe kategorie (Podróże, Zwierzęta, Dom) po dodaniu img-03…img-05
    static let samples: [CategoryView] = [
        CategoryView(id: "food", name: "Jedzenie", imageName: "img-02", lessonCount: 24)
    ]
}
