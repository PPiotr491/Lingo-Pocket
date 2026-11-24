import Foundation

struct Word: Codable, Identifiable, Hashable {
    let id: String
    let englishTerm: String
    let transcription: String
    let translation: String
    let imageName: String
    let audioName: String
}

struct Lesson: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let level: String
    let durationMinutes: Int
    let words: [Word]
}

struct Category: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let imageName: String
    let lessons: [Lesson]
}

extension Category {
    /// Odmiana: „1 lekcja”, „2–4 lekcje”, „5+ lekcji” (z wyjątkiem 12–14).
    var lessonCountText: String {
        let count = lessons.count
        let lastDigit = count % 10
        let lastTwo = count % 100
        if count == 1 { return "1 lekcja" }
        if (2...4).contains(lastDigit) && !(12...14).contains(lastTwo) {
            return "\(count) lekcje"
        }
        return "\(count) lekcji"
    }
}
