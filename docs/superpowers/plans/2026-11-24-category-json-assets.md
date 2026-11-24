# Kategoria z JSON-a + porządek w assetach — plan wykonania

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Usunąć `CategoryView`, zasilić ekrany modelem `Category` z `data.json` i umieścić 20 obrazów z Figmy w assetach pod czytelnymi nazwami w folderach.

**Architecture:** `ContentViewModel` (`@Observable`) wczytuje `data.json` raz, trzyma go `ContentView` jako `@State` i przekazuje `categories` do `HomeView`. `Category` jest `Hashable`, więc to ją niesie trasa `Route.lessons`. Obrazy siedzą w folderach `Assets.xcassets` bez przestrzeni nazw, więc odwołania to same nazwy.

**Tech Stack:** SwiftUI, Observation, Foundation (JSONDecoder), asset catalog Xcode, Figma MCP. Na Windowsie do weryfikacji: `swiftc` 6.4 (Foundation) i Git Bash.

**Spec:** `docs/superpowers/specs/2026-11-24-category-json-assets-design.md`

## Global Constraints

- Ścieżki względem `Lingo-Pocket/`. Grupa `Lingo/` jest synchronizowana z dyskiem (`fileSystemSynchronizedGroups`), więc każdy plik `.swift` wrzucony do `Lingo/` trafia do targetu aplikacji. Narzędzia weryfikujące lądują w `Tools/`, poza `Lingo/`.
- Target: iOS 27.0, `SWIFT_VERSION = 5.0`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.
- Nazwy obrazów: angielskie, kebab-case, globalnie unikalne. Foldery w assetach tylko porządkują: ich `Contents.json` **nie** ma `"provides-namespace"`.
- Odmiana bez zmian: `1 → "1 lekcja"`, końcówka 2–4 (poza 12–14) → `"N lekcje"`, reszta → `"N lekcji"`.
- Tekst UI bez zmian (polski), komentarze w kodzie po polsku, jak dotąd.
- Na tej maszynie nie ma Xcode. Widoków SwiftUI nie kompilujemy lokalnie. Build i uruchomienie robi użytkownik w Xcode.
- Commity na bieżącej gałęzi `data-models-standardize`, wiadomości commitów po angielsku.

## Review Focus

1. Kategoria z 0 lekcji („Podróże”) pokazuje „0 lekcji” i nie psuje kafelka. Test w Task 1.
2. Liczby 12–14, 112, 22, 24 odmieniają się poprawnie. Test w Task 1.
3. Każda nazwa obrazu w `data.json` i w kodzie ma swój imageset, więc żaden kafelek nie jest pusty. Skrypt w Task 3.
4. `data.json` jest wczytywany raz na uruchomienie, a nie przy każdym przerysowaniu `HomeView`: view model żyje w `@State` w `ContentView`. Sprawdzenie w Task 2, krok przeglądu.
5. Niezdekodowany albo brakujący `data.json` daje pustą siatkę i log w konsoli, bez crasha. To zachowanie już istnieje. Task 2 nie może dodać `try!` ani force-unwrapa.

---

### Task 1: Model `Category` gotowy dla widoków

**Files:**
- Modify: `Lingo/DataModel/DataModels.swift`
- Create: `Tools/ModelChecks/main.swift`
- Create: `Tools/run-model-checks.sh`

**Interfaces:**
- Produces: `struct Word: Codable, Identifiable, Hashable`, `struct Lesson: Codable, Identifiable, Hashable`, `struct Category: Codable, Identifiable, Hashable` (pola bez zmian: `id`, `title`, `imageName`, `lessons`), `extension Category { var lessonCountText: String }`.

- [ ] **Step 1: Napisz test** w `Tools/ModelChecks/main.swift`. To prosty program: każda asercja wypisuje `FAIL: …`, na końcu `exit(1)`, jeśli coś padło, inaczej `ALL PASSED`. Ścieżka do JSON-a przychodzi jako `CommandLine.arguments[1]`.

```swift
// pomocnik: Category z n pustymi lekcjami
func category(lessons n: Int) -> Category { ... }

check(category(lessons: 0).lessonCountText == "0 lekcji")
check(category(lessons: 1).lessonCountText == "1 lekcja")
check(category(lessons: 2).lessonCountText == "2 lekcje")
check(category(lessons: 5).lessonCountText == "5 lekcji")
check(category(lessons: 12).lessonCountText == "12 lekcji")
check(category(lessons: 14).lessonCountText == "14 lekcji")
check(category(lessons: 22).lessonCountText == "22 lekcje")
check(category(lessons: 24).lessonCountText == "24 lekcje")
check(category(lessons: 112).lessonCountText == "112 lekcji")

let cats = try JSONDecoder().decode([Category].self, from: Data(contentsOf: jsonURL))
check(cats.map(\.title) == ["Jedzenie", "Podróże"])
check(cats.map(\.lessonCountText) == ["2 lekcje", "0 lekcji"])
check(Set(cats).count == 2)          // Hashable
check(cats[0] == cats[0] && cats[0] != cats[1])
```

- [ ] **Step 2: Napisz `Tools/run-model-checks.sh`.** Kompiluje `Lingo/DataModel/DataModels.swift` razem z `Tools/ModelChecks/main.swift` przez `swiftc` do katalogu z `mktemp -d` i uruchamia wynik z argumentem `Lingo/DataModel/data.json`. Ścieżki liczone od katalogu skryptu, kod wyjścia przekazany dalej.

- [ ] **Step 3: Uruchom i potwierdź, że test pada**

Run: `bash Tools/run-model-checks.sh`
Expected: błąd kompilacji, bo `lessonCountText` nie istnieje, a `Category` nie spełnia `Hashable`.

- [ ] **Step 4: Zmień `DataModels.swift`.** Dodaj `Hashable` do `Word`, `Lesson` i `Category` (wystarczy wersja syntetyzowana). Dodaj `extension Category { var lessonCountText: String }` z logiką przeniesioną z `Lingo/Models/Category.swift`, liczoną z `lessons.count`. Zachowaj polski komentarz z regułą odmiany.

- [ ] **Step 5: Uruchom i potwierdź, że test przechodzi**

Run: `bash Tools/run-model-checks.sh`
Expected: `ALL PASSED`, kod wyjścia 0.

- [ ] **Step 6: Commit**

```bash
git add Lingo/DataModel/DataModels.swift Tools/ModelChecks/main.swift Tools/run-model-checks.sh
git commit -m "feat: make JSON Category Hashable with lesson count text"
```

---

### Task 2: Widoki na `Category`, usunięcie `CategoryView`

**Files:**
- Modify: `Lingo/DataModel/ViewModel.swift`
- Modify: `Lingo/ContentView.swift`
- Modify: `Lingo/Views/HomeView.swift`
- Modify: `Lingo/Views/LessonListView.swift`
- Delete: `Lingo/Models/Category.swift` (razem z pustym folderem `Lingo/Models/`)

**Interfaces:**
- Consumes: `Category`, `Category.lessonCountText` z Task 1.
- Produces:
  - `@Observable final class ContentViewModel { var categories: [Category]; init(); func loadData() }`
  - `ContentView.Route.lessons(Category)`
  - `HomeView(username:streakDays:categories: [Category])`. `categories` nie ma domyślnej wartości.
  - `CategoryTile(category: Category)`, `LessonListView(category: Category)`

- [ ] **Step 1: `ViewModel.swift`.** Zamień `Combine`/`@Published` na `import Observation` + `@Observable`. `loadData()` zostaje jak jest (`guard` + `do/catch`, polskie logi).
- [ ] **Step 2: `ContentView.swift`.** Dodaj `@State private var viewModel = ContentViewModel()`. Ustaw `case lessons(Category)`, a w `.home` wywołaj `HomeView(categories: viewModel.categories)`.
- [ ] **Step 3: `HomeView.swift`.** Zmień typ na `[Category]` bez domyślnej wartości, a w `CategoryTile` użyj `category.title` zamiast `category.name`. W `#Preview` użyj `HomeView(streakDays: 7, categories: ContentViewModel().categories)`.
- [ ] **Step 4: `LessonListView.swift`.** Zmień typ na `Category` i zamień `category.name` na `category.title` w obu miejscach. W `#Preview` przekaż `ContentViewModel().categories[0]`.
- [ ] **Step 5: Usuń `Lingo/Models/Category.swift` i folder `Lingo/Models`.**
- [ ] **Step 6: Weryfikacja**

Run: `grep -rn "CategoryView\|\.name\b\|samples\|@Published\|try!" Lingo --include=*.swift`
Expected: brak wyników.

Run: `bash Tools/run-model-checks.sh`
Expected: `ALL PASSED`.

Przegląd (Review Focus 4–5): `ContentViewModel()` tworzony tylko w `ContentView` (`@State`) i w `#Preview`. Nigdzie w `body`.

- [ ] **Step 7: Commit**

```bash
git add -A Lingo
git commit -m "refactor: drive screens from JSON Category, remove CategoryView"
```

---

### Task 3: Zasoby z Figmy w folderach

**Files:**
- Create: `Tools/check-assets.sh`
- Create: `Lingo/Assets.xcassets/<Folder>/Contents.json` dla folderów `Icons`, `Onboarding`, `Categories`, `Lessons`, `Words`, `Video`, `Quiz`, `Profile`, `Badges`
- Create/Move: imagesety według tabeli „Zasoby” w specu
- Delete: `img-01.imageset`, `img-02.imageset`, `StreakImg.imageset` (po przeniesieniu)
- Modify: `Lingo/DataModel/data.json`, `Lingo/Views/OnboardingView.swift:16`, `Lingo/Views/FlashcardsView.swift:123`

**Interfaces:**
- Consumes: nic z poprzednich tasków.
- Produces: 21 imagesetów o nazwach z tabeli w specu (20 obrazów + `icon-flame`).

- [ ] **Step 1: Napisz `Tools/check-assets.sh`.** Sprawdza trzy rzeczy, wypisuje `FAIL: …` przy każdym błędzie i kończy kodem 1, jeśli coś padło.
  1. Każde z 21 oczekiwanych imagesetów istnieje jako `Lingo/Assets.xcassets/<Folder>/<nazwa>.imageset`, w folderze z tabeli specu, i ma plik obrazu wymieniony w swoim `Contents.json`.
  2. Każda nazwa z `"imageName": "…"` w `data.json`, z `Image("…")` i z `imageName: "…"` w plikach `.swift` ma swój imageset gdziekolwiek w katalogu.
  3. Nie istnieje żaden `img-*.imageset` ani `StreakImg.imageset`, a żaden folderowy `Contents.json` nie zawiera `provides-namespace`.
- [ ] **Step 2: Uruchom i potwierdź, że pada**

Run: `bash Tools/check-assets.sh`
Expected: FAIL m.in. dla `category-travel`, `word-apple` i `img-03`.

- [ ] **Step 3: Pobierz obrazy z Figmy.** Zaloguj się przez `mcp__plugin_figma_figma__authenticate`. Użytkownik musi zatwierdzić logowanie w przeglądarce. W pliku `01r07GUrb57h40qxKM2Mxo` znajdź sekcję „Zasoby – 20 różnych obrazów” i dla każdego z img-01…img-20 wyeksportuj węzeł w @2x i @3x. Zdjęcia mogą być w JPG, ilustracje i odznaki w PNG. Pliki zapisz najpierw do świeżego katalogu w scratchpadzie i obejrzyj każdy, żeby sprawdzić, czy obrazek pasuje do opisu w tabeli. Jeśli MCP nie potrafi wyeksportować obrazu w pełnej rozdzielczości, zatrzymaj się i zgłoś to, zamiast wstawiać zrzuty niskiej jakości.
- [ ] **Step 4: Zbuduj katalog.** Każdy folder dostaje `Contents.json` z samym `{"info":{"author":"xcode","version":1}}`. Każdy imageset to `<nazwa>.imageset/` z plikami `<nazwa>@2x.<ext>` i `<nazwa>@3x.<ext>` oraz `Contents.json` w formacie istniejących setów (sloty 1x/2x/3x, 1x pusty). `icon-flame.imageset` przenieś do `Icons/` bez zmian. Dla 01 i 02 weź wersję z Figmy, jeśli jest tej samej albo lepszej jakości niż obecny plik, inaczej przemianuj obecny. Usuń `StreakImg.imageset`.
- [ ] **Step 5: Zaktualizuj odwołania.** `data.json`: `img-02 → category-food`, `img-03 → category-travel`, `img-11 → word-apple`. `OnboardingView`: `"img-01" → "onboarding-hero"`. Podgląd `FlashcardsView`: `"img-11" → "word-apple"`.
- [ ] **Step 6: Weryfikacja**

Run: `bash Tools/check-assets.sh && bash Tools/run-model-checks.sh`
Expected: oba kończą się powodzeniem (`ALL PASSED`).

- [ ] **Step 7: Commit**

```bash
git add -A Lingo/Assets.xcassets Lingo/DataModel/data.json Lingo/Views Tools/check-assets.sh
git commit -m "feat: add 20 mockup images to assets with folders and descriptive names"
```

---

### Po wszystkich taskach
- Commit specu i planu: `git add docs/superpowers && git commit -m "docs: add Category and assets spec and plan"`.
- Przekazanie użytkownikowi: zbudować w Xcode (⌘B) i przejść Onboarding → Home (2 kafelki: „Jedzenie – 2 lekcje” ze zdjęciem warzyw, „Podróże – 0 lekcji” z tramwajem) → kafelek → Lista lekcji z tytułem kategorii.
