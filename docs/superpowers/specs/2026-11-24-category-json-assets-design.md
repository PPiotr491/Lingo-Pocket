# Kategoria z JSON-a + porządek w Assets.xcassets — projekt (mała zmiana)

## Cel i powód
`CategoryView` powstało osobno, z danymi wpisanymi na sztywno tylko po to, by pokazać layout.
Ma zniknąć — wszystkie ekrany korzystają z `Category` wczytanej z `data.json`.
Przy okazji wszystkie obrazy z makiety (img-01…img-20) trafiają do assetów pod czytelnymi
nazwami, w folderach.

## Cele
- Jeden model kategorii: `Category` (z `DataModels.swift`); `CategoryView` i `Models/Category.swift` usunięte.
- Home pokazuje kategorie z `data.json` (dziś: „Jedzenie – 2 lekcje”, „Podróże – 0 lekcji”).
- Logika i nawigacja bez zmian: kafelek kategorii → Lista lekcji, ta sama odmiana „lekcja/lekcje/lekcji”.
- Wszystkie 20 obrazów z Figmy w assetach, pogrupowane w folderach, z opisowymi nazwami.

## Poza zakresem
- Uzupełnianie treści `data.json` (lekcje, słówka, kolejne kategorie).
- Nowe ekrany, Tab Bar, zmiany wyglądu.
- Aktualizacja PDF-a (tabela 4.1 nadal mówi o nazwach img-XX).

## Podejścia (folderów w assetach)
1. **Foldery tylko porządkujące — wybrane.** Nazwy globalnie unikalne, w kodzie i JSON-ie `"category-travel"`;
   przeniesienie między folderami niczego nie psuje.
2. Foldery z przestrzenią nazw (`"Categories/travel"`) — krótsze nazwy plików, ale ścieżki w kodzie i danych,
   każda zmiana folderu psuje odwołania. Odrzucone.
3. Zostawić nazwy img-XX (zgodnie z PDF-em) — odrzucone, bo celem jest czytelność.

## Zasoby (Figma: plik „Lingo Pocket – makieta”, sekcja „Zasoby – 20 różnych obrazów”)

| Folder | Nazwa | Było | Opis |
|---|---|---|---|
| Icons | icon-flame | icon-flame | płomień w pigułce serii (bez zmian) |
| Onboarding | onboarding-hero | img-01 | ilustracja hero |
| Categories | category-food | img-02 | Jedzenie |
| Categories | category-travel | img-03 | Podróże |
| Categories | category-animals | img-04 | Zwierzęta |
| Categories | category-home | img-05 | Dom |
| Lessons | lesson-breakfast | img-06 | Śniadanie |
| Lessons | lesson-cafe | img-07 | W kawiarni |
| Lessons | lesson-market | img-08 | Na targu |
| Lessons | lesson-restaurant | img-09 | W restauracji |
| Lessons | lesson-groceries | img-10 | Zakupy spożywcze |
| Words | word-apple | img-11 | fiszka: apple |
| Video | video-cafe-poster | img-12 | plakat wideo „W kawiarni” |
| Quiz | quiz-cheese | img-13 | cheese |
| Quiz | quiz-bread | img-14 | bread |
| Quiz | quiz-banana | img-15 | banana |
| Quiz | quiz-tomato | img-16 | tomato |
| Profile | profile-avatar | img-17 | awatar użytkownika |
| Badges | badge-streak | img-18 (= StreakImg) | odznaka: seria dni |
| Badges | badge-words | img-19 | odznaka: słówka |
| Badges | badge-quiz | img-20 | odznaka: quiz |

- `StreakImg` (nieużywany duplikat img-18) zastępuje `badge-streak`.
- Obecne pliki img-01 i img-02 zostają (przemianowane), chyba że wersja z Figmy jest wyraźnie lepszej jakości.
- **Moja decyzja:** eksport PNG w @2x i @3x (zgodnie z rozdz. 7 PDF-a), zdjęcia mogą być JPG.

## Zmiany w kodzie
- `DataModels.swift`: `Word`, `Lesson`, `Category` dostają `Hashable` (Category jest częścią trasy nawigacji);
  `lessonCountText` przenosi się do rozszerzenia `Category` (liczy z `lessons.count`), nazwa pola `name` → `title`.
- `ViewModel.swift`: `ContentViewModel` jako `@Observable` (projekt celuje w iOS 27, PDF przewiduje `@Observable`).
- `ContentView`: trzyma view model (`@State`), `Route.lessons(Category)`, przekazuje `viewModel.categories` do `HomeView`.
- `HomeView`, `CategoryTile`, `LessonListView`: typ `Category`, `category.title`. Podglądy (#Preview) biorą dane z `data.json`.
- `data.json`, `OnboardingView`, podgląd `FlashcardsView`: nowe nazwy obrazów.

## Ograniczenia i weryfikacja
- Brak Xcode na tym komputerze (Windows) — SwiftUI nie skompiluje się lokalnie.
  Weryfikacja tutaj: skrypt Swift (Foundation) dekodujący `data.json` modelami z `DataModels.swift`
  i sprawdzający `lessonCountText`, plus kontrola, że każda nazwa obrazu w kodzie/JSON-ie istnieje w assetach.
  Ostateczny build i uruchomienie — w Xcode na Macu.
- Pobranie z Figmy wymaga zalogowania przez Figma MCP.

## Zostawione budującemu
Dokładne miejsce rozszerzenia `lessonCountText`, układ plików `Contents.json`.
