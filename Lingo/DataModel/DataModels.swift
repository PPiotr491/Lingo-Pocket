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
    let video: VideoContent?
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

enum SubtitleLanguage: String, CaseIterable, Hashable {
    case english, polish, off

    var label: String {
        switch self {
        case .english: return "EN"
        case .polish: return "PL"
        case .off: return "Wyłącz"
        }
    }
}

struct SubtitleLine: Codable, Hashable {
    let start: Double
    let end: Double
    let en: String
    let pl: String
}

struct VideoContent: Codable, Hashable {
    let fileName: String
    let title: String
    let description: String
    let subtitles: [SubtitleLine]

    /// Kwestia widoczna w danej chwili: początek włącznie, koniec rozłącznie.
    func subtitle(at time: Double, language: SubtitleLanguage) -> String? {
        guard language != .off,
              let line = subtitles.first(where: { time >= $0.start && time < $0.end })
        else { return nil }
        return language == .english ? line.en : line.pl
    }
}

extension Lesson {
    /// „1 nowe słówko”, „2–4 nowe słówka” (poza 12–14), reszta „nowych słówek”; brak słówek → nil.
    var newWordsText: String? {
        let count = words.count
        if count == 0 { return nil }
        let lastDigit = count % 10
        let lastTwo = count % 100
        if count == 1 { return "1 nowe słówko" }
        if (2...4).contains(lastDigit) && !(12...14).contains(lastTwo) {
            return "\(count) nowe słówka"
        }
        return "\(count) nowych słówek"
    }
}

/// Czas filmu jako m:ss, z ucięciem ułamka sekundy.
func formattedVideoDuration(_ seconds: Double) -> String {
    guard seconds.isFinite else { return "0:00" }
    let total = max(0, Int(seconds))
    return String(format: "%d:%02d", total / 60, total % 60)
}
