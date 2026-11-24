import Foundation

var failed = false
func check(_ condition: Bool, _ message: String = "", line: Int = #line) {
    if !condition {
        print("FAIL (linia \(line)): \(message)")
        failed = true
    }
}

// Pomocnik: Category z n pustymi lekcjami
func category(lessons n: Int) -> Category {
    let lessons = (0..<n).map { Lesson(id: "l\($0)", title: "Lekcja \($0)", level: "A1", durationMinutes: 5, words: [], video: nil) }
    return Category(id: "c", title: "Test", imageName: "img", lessons: lessons)
}

// Pomocnik: Lesson z n słówkami, video nil
func lesson(words n: Int) -> Lesson {
    let words = (0..<n).map { Word(id: "w\($0)", englishTerm: "e", transcription: "t", translation: "p", imageName: "i", audioName: "a") }
    return Lesson(id: "l", title: "L", level: "A1", durationMinutes: 5, words: words, video: nil)
}

check(category(lessons: 0).lessonCountText == "0 lekcji")
check(category(lessons: 1).lessonCountText == "1 lekcja")
check(category(lessons: 2).lessonCountText == "2 lekcje")
check(category(lessons: 5).lessonCountText == "5 lekcji")
check(category(lessons: 12).lessonCountText == "12 lekcji")
check(category(lessons: 14).lessonCountText == "14 lekcji")
check(category(lessons: 22).lessonCountText == "22 lekcje")
check(category(lessons: 24).lessonCountText == "24 lekcje")
check(category(lessons: 112).lessonCountText == "112 lekcji")
check(category(lessons: 11).lessonCountText == "11 lekcji")
check(category(lessons: 13).lessonCountText == "13 lekcji")
check(category(lessons: 21).lessonCountText == "21 lekcji")

guard CommandLine.arguments.count > 1 else {
    print("FAIL: brak ścieżki do JSON-a")
    exit(1)
}
let jsonURL = URL(fileURLWithPath: CommandLine.arguments[1])
let cats = try JSONDecoder().decode([Category].self, from: Data(contentsOf: jsonURL))
check(cats.map(\.title) == ["Jedzenie", "Podróże"], "tytuły")
check(cats.map(\.lessonCountText) == ["2 lekcje", "0 lekcji"], "liczba lekcji")
check(Set(cats).count == 2)          // Hashable
check(cats[0] != cats[1])

let video = VideoContent(fileName: "x", title: "t", description: "d", subtitles: [
    SubtitleLine(start: 0.0, end: 3.5, en: "A-en", pl: "A-pl"),
    SubtitleLine(start: 3.5, end: 7.0, en: "B-en", pl: "B-pl"),
])
check(video.subtitle(at: 0.0, language: .english) == "A-en")
check(video.subtitle(at: 3.49, language: .polish) == "A-pl")
check(video.subtitle(at: 3.5, language: .english) == "B-en")   // początek włącznie, koniec rozłącznie
check(video.subtitle(at: 7.0, language: .english) == nil)
check(video.subtitle(at: -1.0, language: .english) == nil)
check(video.subtitle(at: 1.0, language: .off) == nil)
check(SubtitleLanguage.allCases.map(\.label) == ["EN", "PL", "Wyłącz"])

check(lesson(words: 0).newWordsText == nil)
check(lesson(words: 1).newWordsText == "1 nowe słówko")
check(lesson(words: 2).newWordsText == "2 nowe słówka")
check(lesson(words: 5).newWordsText == "5 nowych słówek")
check(lesson(words: 12).newWordsText == "12 nowych słówek")
check(lesson(words: 22).newWordsText == "22 nowe słówka")

check(formattedVideoDuration(10.01) == "0:10")
check(formattedVideoDuration(165) == "2:45")
check(formattedVideoDuration(59.9) == "0:59")

// z data.json
let cafe = cats[0].lessons[1]
check(cafe.id == "les_2" && cafe.video?.fileName == "cafe_lesson")
check(cafe.video?.title == "W kawiarni – zamawiamy kawę")
check(cafe.video?.subtitles.count == 3)
check(cafe.video?.subtitle(at: 8.0, language: .polish) == "Nie, dziękuję. Ile płacę?")
check(cats[0].lessons[0].video == nil)

if failed { exit(1) }
print("ALL PASSED")
