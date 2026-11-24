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
    let lessons = (0..<n).map { Lesson(id: "l\($0)", title: "Lekcja \($0)", level: "A1", durationMinutes: 5, words: []) }
    return Category(id: "c", title: "Test", imageName: "img", lessons: lessons)
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

guard CommandLine.arguments.count > 1 else {
    print("FAIL: brak ścieżki do JSON-a")
    exit(1)
}
let jsonURL = URL(fileURLWithPath: CommandLine.arguments[1])
let cats = try JSONDecoder().decode([Category].self, from: Data(contentsOf: jsonURL))
check(cats.map(\.title) == ["Jedzenie", "Podróże"], "tytuły")
check(cats.map(\.lessonCountText) == ["2 lekcje", "0 lekcji"], "liczba lekcji")
check(Set(cats).count == 2)          // Hashable
check(cats[0] == cats[0] && cats[0] != cats[1])

if failed { exit(1) }
print("ALL PASSED")
