import Foundation

struct Word: Codable, Identifiable {
    let id: String
    let englishTerm: String
    let transcription: String
    let translation: String
    let imageName: String
    let audioName: String
}

struct Lesson: Codable, Identifiable {
    let id: String
    let title: String
    let level: String
    let durationMinutes: Int
    let words: [Word]
}

struct Category: Codable, Identifiable {
    let id: String
    let title: String
    let imageName: String
    let lessons: [Lesson]
}
