# Ekran 05 – Lekcja wideo — plan wykonania

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dodać niepodłączony ekran `VideoLessonView` dla lekcji „W kawiarni”: systemowy odtwarzacz z przyciętym obrazem, napisy EN/PL/Wyłącz z `data.json`, opis lekcji i przycisk quizu.

**Architecture:** Model (Foundation, testowalny na Windowsie) dostaje `VideoContent` przy `Lesson` i czyste funkcje: wybór napisu dla chwili i języka, odmianę „słówek”, format czasu. Widok trzyma `AVPlayer` i podaje go razem z filmem i językiem do `AVPlayerViewController` (przez `UIViewControllerRepresentable`, `videoGravity = .resizeAspectFill`, w pełnym ekranie `.resizeAspect`). Koordynator odtwarzacza ma własny `addPeriodicTimeObserver` i sam podmienia `captionHost.rootView` w `contentOverlayView`, więc napisy odświeżają się także w pełnym ekranie.

**Tech Stack:** SwiftUI, AVKit/AVFoundation, Foundation (JSONDecoder). Weryfikacja na Windowsie: `swiftc` i Git Bash.

**Spec:** `docs/superpowers/specs/2026-11-24-video-lesson-screen-design.md`

## Global Constraints

- Ścieżki względem `Lingo-Pocket/`, gałąź `video-lesson-screen`, wiadomości commitów po angielsku z linią `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- `Lingo/` to grupa synchronizowana z dyskiem: każdy plik w niej trafia do aplikacji. Narzędzia lądują w `Tools/`.
- iOS 27, Swift 5, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Brak Xcode na tej maszynie: kod SwiftUI weryfikuje CI na PR i Xcode użytkownika.
- Ekran **nie jest podłączony** do nawigacji: bez zmian w `ContentView`, `LessonListView` i innych ekranach. „Przejdź do quizu” nie ma akcji, nie ma Tab Bara.
- Tekst UI po polsku, komentarze po polsku. Pliki ze znakami końca linii CRLF zostają w CRLF.
- Film: `Lingo/Media/cafe_lesson.mp4` (10 s, 720×1280, bez dźwięku).

## Review Focus

1. Brak pliku filmu w paczce → zamiast odtwarzacza komunikat „Nie znaleziono filmu.”, bez crasha. Task 2, krok przeglądu, oraz `check-assets.sh` w Task 1 (plik z `data.json` musi istnieć).
2. Lekcja bez wideo (`video == nil`) → komunikat „Ta lekcja nie ma jeszcze wideo.”, bez crasha. Task 2, krok przeglądu.
3. Granice czasu napisów: chwila równa końcowi jednej kwestii i początkowi następnej, czas przed pierwszą i po ostatniej kwestii. Test w Task 1.
4. Wyjście z ekranu w trakcie odtwarzania → odtwarzanie zatrzymane (`onDisappear`, pominięte w pełnym ekranie), obserwator czasu usunięty w `dismantleUIViewController`. Wejście w pełny ekran i wyjście z niego nie pauzują i nie usuwają obserwatora. Task 2, krok przeglądu.
5. Zmiana języka w trakcie odtwarzania działa od razu, a „Wyłącz” chowa napis. Test w Task 1 (funkcja), Task 2 (napis liczony z bieżącego języka, nie zapamiętany).

---

### Task 0: Kalibracja sprawdzania ekranu (robi kontroler, nie wykonawca)

- [ ] W tymczasowym worktree poza repo (`mktemp -d`, `git worktree add`) zmień w kopii `Lingo/Views/HomeView.swift` jedną rzecz w linii, którą HomeView spełnia: wagę tytułu z `.bold` na `.semibold`, rozmiar 28 bez zmian. Oddaj kopię recenzentowi z `ui-consistency:verifying` i listą kontrolną z Task 2, mówiąc tylko, że kopia gdzieś odbiega od listy. Recenzent nie otwiera oryginału.
- [ ] Zaliczone, jeśli recenzent zgłosi różnicę wagi tytułu. Jeśli nie, sprawdzanie jest ślepe na takie różnice: zgłoś to przed zbudowaniem ekranu. Wynik zapisz w ledgerze: co testował plant, czego nie testował żaden. Usuń worktree.

---

### Task 1: Model lekcji wideo i plik filmu

**Files:**
- Modify: `Lingo/DataModel/DataModels.swift`
- Modify: `Lingo/DataModel/data.json` (lekcja `les_2`)
- Create: `Lingo/Media/cafe_lesson.mp4` (przeniesiony z `cafe_lesson.mp4` w katalogu repo)
- Modify: `Tools/ModelChecks/main.swift`, `Tools/check-assets.sh`

**Interfaces:**
- Produces (w `DataModels.swift`):
  - `enum SubtitleLanguage: String, CaseIterable, Hashable { case english, polish, off }` z `var label: String` (`"EN"`, `"PL"`, `"Wyłącz"`)
  - `struct SubtitleLine: Codable, Hashable { let start: Double; let end: Double; let en: String; let pl: String }`
  - `struct VideoContent: Codable, Hashable { let fileName: String; let title: String; let description: String; let subtitles: [SubtitleLine] }` z `func subtitle(at time: Double, language: SubtitleLanguage) -> String?`
  - `Lesson` dostaje `let video: VideoContent?`. Brak klucza w JSON-ie daje `nil`.
  - `extension Lesson { var newWordsText: String? }`
  - `func formattedVideoDuration(_ seconds: Double) -> String`

- [ ] **Step 1: Dopisz testy** do `Tools/ModelChecks/main.swift`, w istniejącym stylu `check(...)`:

```swift
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

// lesson(words:) — pomocnik: Lesson z n słówkami, video nil
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
```

- [ ] **Step 2: Dopisz do `Tools/check-assets.sh` czwarte sprawdzenie.** Każde `"fileName": "<x>"` z `data.json` musi istnieć jako `Lingo/Media/<x>.mp4`, inaczej `FAIL: …`.
- [ ] **Step 3: Uruchom i potwierdź, że oba skrypty padają**

Run: `bash Tools/run-model-checks.sh; bash Tools/check-assets.sh`
Expected: błąd kompilacji (brak `VideoContent`) oraz `FAIL` dla `cafe_lesson`.

- [ ] **Step 4: Zaimplementuj** typy i funkcje z Interfaces w `DataModels.swift`. Odmiana słówek działa jak `lessonCountText`: 1 → „nowe słówko”, końcówka 2–4 poza 12–14 → „nowe słówka”, reszta → „nowych słówek”, 0 → `nil`. Czas formatuj jako minuty i sekundy z zerem wiodącym, ucinając ułamek sekundy. Do `les_2` w `data.json` dopisz blok `"video"` dokładnie ze specu (sekcja *Moja decyzja — dane*). Przenieś film do `Lingo/Media/cafe_lesson.mp4`.
- [ ] **Step 5: Uruchom i potwierdź, że przechodzą**

Run: `bash Tools/run-model-checks.sh && bash Tools/check-assets.sh`
Expected: dwa razy `ALL PASSED`.

- [ ] **Step 6: Commit**

```bash
git add Lingo/DataModel Lingo/Media/cafe_lesson.mp4 Tools
git commit -m "feat: add video lesson content model and cafe lesson video"
```

---

### Task 2: Ekran `VideoLessonView`

**Files:**
- Create: `Lingo/Views/VideoLessonView.swift` (ekran oraz prywatne `LessonVideoPlayer` i `SubtitlePicker`: zgoda użytkownika na trzymanie ich w pliku ekranu)
- Modify: `Lingo/Theme/Theme.swift` (propozycja A przyjęta)

**Interfaces:**
- Consumes: `Lesson`, `VideoContent`, `SubtitleLanguage`, `VideoContent.subtitle(at:language:)`, `Lesson.newWordsText`, `formattedVideoDuration(_:)` z Task 1. `ContentViewModel` (tylko w `#Preview`).
- Produces: `struct VideoLessonView: View { init(lesson: Lesson) }`. Nikt go jeszcze nie wywołuje poza `#Preview`.

**Wzór:** `Lingo/Views/HomeView.swift`. Lista kontrolna (migawka kodu z 2026-11-24, kod ma pierwszeństwo):

VideoLessonView jako „ekran” (słowo projektu: komentarze „Ekran 0X”, wszystkie ekrany w `Lingo/Views`), wzór HomeView, 4 członków z 5 kandydatów (odpada `ContentView`, bo tylko przełącza ekrany), w aplikacji Lingo.

- [ ] **Szkielet ekranu.** `ScrollView { VStack(alignment: .leading, spacing: 24) }`, `.padding(.horizontal, 16)`, `.padding(.top, 8)`, tło `Color.lingoBackground.ignoresSafeArea()`. Tło z `ignoresSafeArea` i margines 16: większość, 3 z 4 plików (Flashcards inaczej). Przewijanie: tylko HomeView, więc decyduje wzór (poziom 7). Wyszukiwanie: `lingoBackground|ignoresSafeArea|padding\(\.horizontal|ScrollView` w 4 widokach.
- [ ] **Pasek nawigacji.** `.navigationTitle(lesson.title)` + `.navigationBarTitleDisplayMode(.inline)`, systemowy „Wstecz”, bez `navigationBarBackButtonHidden`. Makieta pokazuje pasek z tytułem. Tylko LessonListView pisze tytuł nawigacji, więc wzorem jest jej sposób. Wyszukiwanie: `navigationTitle|navigationBarTitleDisplayMode`.
- [ ] **Ramka filmu.** `LessonVideoPlayer` (nowy, zgoda użytkownika), proporcje 16:9 na pełną szerokość treści, `.clipShape(RoundedRectangle(cornerRadius: 16))`. Promień 16 jak w `CategoryTile` i `PrimaryButtonStyle` (4 użycia w 3 plikach). Wyszukiwanie: `RoundedRectangle\(cornerRadius`.
- [ ] **Napis na obrazie.** Przy dolnej krawędzi: tekst `.font(.system(size: 15, weight: .semibold))`, `.foregroundStyle(.white)`, tło `Color.lingoCaptionBackground` (propozycja A przyjęta przez użytkownika: nowy wpis w `Theme.swift`), `RoundedRectangle(cornerRadius: 8)`, padding 12 poziomo i 4 pionowo. Zmiana kwestii z przenikaniem 0,2 s. Brak napisu albo „Wyłącz” → nic. Biały tekst na tle: `.white` na kolorze, jak w `PrimaryButtonStyle`. Wartości z siatki 4.
- [ ] **Tytuł lekcji.** `Text(video.title)`, `.font(.system(size: 28, weight: .bold))`, `lingoTextPrimary`. Brak konwencji: 28 (HomeView) i 30 (OnboardingView). Nowszy, HomeView, pisze 28 (poziom 5). Bez `.accessibilityAddTraits(.isHeader)`: jak 4 z 4 ekranów, propozycja B odrzucona przez użytkownika.
- [ ] **Metadane.** „Poziom {level} · {formattedVideoDuration} min”, a „ · {newWordsText}”, gdy jest. `.font(.system(size: 15))`, `lingoTextSecondary`, tak jak tekst drugorzędny w karcie HomeView. Długość filmu wczytana z pliku. Do czasu wczytania sam „Poziom {level}”.
- [ ] **Przełącznik napisów.** `HStack`: „Napisy:” (15, `lingoTextSecondary`) i trzy `Button` z `.buttonStyle(.plain)`, po jednym na `SubtitleLanguage.allCases`, z etykietą `label`. Kapsuła: wybrana `lingoAccent` z białym tekstem 15 semibold, pozostałe `lingoAccentSoft` z tekstem `lingoAccent`. Padding 12 poziomo i 8 pionowo, jak pigułka serii w HomeView (`Capsule()` + 12/8). Domyślnie `.english`, a wybrana pigułka ma `.accessibilityAddTraits(.isSelected)`. Nowy element, zgoda użytkownika.
- [ ] **Karta „Opis lekcji”.** `VStack(alignment: .leading, spacing: 8)`, padding 16, tło `Color.lingoSurface`, `.clipShape(RoundedRectangle(cornerRadius: 16))`, `.lingoCardShadow()`. Nagłówek „Opis lekcji” 17 semibold `lingoTextPrimary`, treść `video.description` 15 `lingoTextSecondary`. Wspólny cień `lingoCardShadow()` (poziom 4). Flashcards rysuje cień ręcznie i tego nie kopiujemy. Wyszukiwanie: `lingoCardShadow|\.shadow\(`.
- [ ] **Przycisk quizu.** `Button("Przejdź do quizu") {}` + `.buttonStyle(PrimaryButtonStyle())`, na pełną szerokość, na końcu treści. Wspólny styl (poziom 4): używają go 2 z 3 ekranów z głównym przyciskiem, Flashcards pisze przycisk ręcznie. Wyszukiwanie: `PrimaryButtonStyle|Color\.blue`.
- [ ] **Brak filmu.** W miejscu ramki 16:9: `Color.lingoAccentSoft` w `RoundedRectangle(cornerRadius: 16)`, na środku tekst 15 `lingoTextSecondary`. Treść: „Nie znaleziono filmu.”, gdy pliku nie ma w paczce, albo „Ta lekcja nie ma jeszcze wideo.”, gdy `video == nil` (wtedy bez tytułu wideo, metadanych, przełącznika i opisu, ale z przyciskiem quizu). Żaden ekran nie ma takiego stanu. Nowe teksty do przeczytania przez człowieka.
- [ ] **Kolor i odstępy przez `Theme.swift`.** Żadnego `Color.blue` ani `.gray`, odstępy na siatce 4 (projekt pisze 4, 8, 12, 16, 20, 24 w 3 plikach). Ozdobne elementy `.accessibilityHidden(true)`, jak w HomeView i Onboarding.
- [ ] **Nie kopiować z HomeView:** powitania, pigułki serii, siatki kategorii, `.navigationBarBackButtonHidden(true)`, tła karty `lingoAccentSoft` z `continueCard`. **Z FlashcardsView:** ręcznie rysowanych przycisków, `Color.blue`/`.gray`, własnego cienia i własnego nagłówka zamiast paska nawigacji.

Zachowanie (decyzje wykonawcy w ramach specu): `AVPlayer` tworzony raz na ekran (`@State`). Napis prowadzi koordynator `LessonVideoPlayer`: własny `addPeriodicTimeObserver` co 0,1 s, napis liczony z czasu odtwarzacza i bieżącego języka, `captionHost.rootView` (`UIHostingController` w `contentOverlayView`) podmieniany tylko przy zmianie kwestii, więc napisy odświeżają się także w pełnym ekranie. `updateUIViewController` przekazuje język i odtwarzacz i od razu odświeża napis (także w pauzie). Obserwator usuwany w `dismantleUIViewController` i przy zmianie odtwarzacza. `onDisappear` tylko pauzuje, z pominięciem w pełnym ekranie (flaga z delegata `AVPlayerViewControllerDelegate`). W pełnym ekranie `videoGravity = .resizeAspect`, po powrocie `.resizeAspectFill`. Brak autoodtwarzania.

- [ ] **Step 1:** Przeczytaj listę kontrolną jeszcze raz przed pisaniem. Nie pracuj z pamięci.
- [ ] **Step 2:** Dodaj `static let lingoCaptionBackground = Color.black.opacity(0.6)` w `Theme.swift`, z polskim komentarzem jak przy pozostałych kolorach.
- [ ] **Step 3:** Napisz `Lingo/Views/VideoLessonView.swift` z `#Preview`: `NavigationStack { VideoLessonView(lesson: <les_2 z ContentViewModel().categories>) }`, lekcja wyszukana po `id == "les_2"`.
- [ ] **Step 4: Weryfikacja**

Run: `bash Tools/run-model-checks.sh && bash Tools/check-assets.sh && grep -nE "Color\.blue|\.gray|navigationBarBackButtonHidden|try!" Lingo/Views/VideoLessonView.swift; git diff --stat`
Expected: dwa razy `ALL PASSED`, grep bez wyników, zmienione tylko pliki z listy Files.

Przegląd (Review Focus 1, 2, 4): brak pliku i `video == nil` prowadzą do komunikatu, nie do force-unwrapa. `onDisappear` pauzuje (poza pełnym ekranem), a `dismantleUIViewController` usuwa obserwatora.

- [ ] **Step 5: Commit**

```bash
git add Lingo/Views/VideoLessonView.swift Lingo/Theme/Theme.swift
git commit -m "feat: add video lesson screen with subtitles"
```

- [ ] **Step 6:** Zgłoś ekran do sprawdzenia. Recenzent tego zadania dostaje listę kontrolną i `ui-consistency:verifying`, a nie jest autorem ani agentem z kalibracji. Popraw to, co zgłosi.
- [ ] **Step 7:** Zgłoś status: `done` po zaliczonym sprawdzeniu albo `parked — <powód>`.

---

### Po zadaniach
- Commit planu: `git add docs/superpowers/plans && git commit -m "docs: add video lesson screen plan"`.
- Przekazanie: build w CI na PR albo w Xcode (⌘B). W podglądzie `VideoLessonView` film się odtwarza, obraz wypełnia ramkę, napisy przełączają się EN/PL/Wyłącz, są widoczne też w pełnym ekranie i znikają po 10 s.
