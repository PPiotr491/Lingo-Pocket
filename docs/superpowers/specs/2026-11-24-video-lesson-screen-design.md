# Ekran 05 – Lekcja wideo — projekt (mała zmiana)

## Cel i powód
Ekran 05 z makiety (PDF, rozdz. 5.5): krótka lekcja wideo z napisami EN/PL. Spełnia wymaganie
prowadzącego „min. 1 film odtwarzany w aplikacji”. Na razie ekran **nie jest podłączony** do innych
ekranów — oglądany przez `#Preview`. Film `cafe_lesson.mp4` jest tymczasowy (10 s, pionowy 720×1280,
bez dźwięku); docelowe nagranie podmieni się bez zmian w kodzie.

## Cele
- Ekran `VideoLessonView` dla lekcji „W kawiarni” (`les_2`): systemowy odtwarzacz Apple, napisy
  EN / PL / Wyłącz nałożone na obraz, tytuł, linia metadanych, karta „Opis lekcji”, przycisk „Przejdź do quizu”.
- Treść lekcji wideo (plik, tytuł, opis, napisy) w `data.json`, przy lekcji „W kawiarni”.

## Poza zakresem
- Nawigacja: wejście z Listy lekcji, akcja „Przejdź do quizu” (przycisk bez akcji), Tab Bar.
- Plakat z dużym przyciskiem Play i animacja Play (wariant 3 — może przyjść później).
- Prawdziwe napisy zsynchronizowane z mową (film nie ma dźwięku).

## Podejścia (odtwarzacz)
1. Własne kontrolki jak w makiecie — najwierniejsze, najwięcej kodu, pełny ekran do zrobienia samemu.
2. **Systemowy odtwarzacz Apple (AVKit) — wybrane.** Gotowe kontrolki, pauza, przewijanie, pełny ekran;
   wygląd systemowy zamiast makietowego.
3. Plakat i Play jak w makiecie, po starcie systemowy odtwarzacz — odłożone na później.

## Decyzje
- **Użytkownik:** wariant 2; obraz przycięty do ramki (wypełnia ją, bez czarnych pasów);
  dane lekcji w `data.json` przy „W kawiarni”.
- **Moja decyzja — przycięcie:** SwiftUI `VideoPlayer` zawsze dopasowuje obraz z pasami, więc odtwarzacz
  to `AVPlayerViewController` (ten sam systemowy odtwarzacz, który `VideoPlayer` opakowuje) przez
  `UIViewControllerRepresentable`, z `videoGravity = .resizeAspectFill`. Ramka 16:9 na pełną szerokość
  treści, zaokrąglenie 16 (jak kafelki).
- **Użytkownik — odrzucony SwiftUI `VideoPlayer`:** rozważony na prośbę użytkownika, odrzucony, bo nie
  pozwala przyciąć obrazu bez ucinania kontrolek, a jego nakładka (`videoOverlay`) nie pokazuje napisów
  w pełnym ekranie. Zostaje `AVPlayerViewController`.
- **Moja decyzja — napisy:** nakładka na obraz (`contentOverlayView`), więc widać je też w pełnym ekranie.
  Biały tekst na półprzezroczystym ciemnym tle przy dolnej krawędzi; zmiana kwestii z fade 0,2 s (PDF).
  Domyślnie EN. Przełącznik EN / PL / Wyłącz jako pigułki jak w makiecie (aktywna: `lingoAccent` z białym
  tekstem, nieaktywne: `lingoAccentSoft` z tekstem w kolorze akcentu).
- **Moja decyzja — dane:** `Lesson` dostaje opcjonalne pole `video: VideoContent?` (inne lekcje go nie mają):

```json
"video": {
  "fileName": "cafe_lesson",
  "title": "W kawiarni – zamawiamy kawę",
  "description": "Nauczysz się zamawiać napoje i płacić w kawiarni. Zwróć uwagę na zwroty „Could I have…?” oraz „I'd like…”.",
  "subtitles": [
    { "start": 0.0, "end": 3.5, "en": "Could I have a coffee with milk, please?", "pl": "Poproszę kawę z mlekiem." },
    { "start": 3.5, "end": 7.0, "en": "Sure. Anything else?", "pl": "Jasne. Coś jeszcze?" },
    { "start": 7.0, "end": 10.0, "en": "No, thank you. How much is it?", "pl": "Nie, dziękuję. Ile płacę?" }
  ]
}
```

  Wyszukanie kwestii dla danej chwili i języka to czysta funkcja w modelu (testowalna bez Xcode).
- **Moja decyzja — metadane:** „Poziom {level} · {długość filmu m:ss} min”, a „· N nowych słówek” tylko
  gdy lekcja ma słówka (odmiana: 1 nowe słówko, 2–4 nowe słówka poza 12–14, reszta nowych słówek).
  Długość filmu odczytana z pliku, nie z `durationMinutes`.
- **Moja decyzja — plik filmu:** `Lingo/Media/cafe_lesson.mp4` (folder na multimedia; trafia do paczki
  aplikacji przez zsynchronizowaną grupę). Brak pliku → zamiast odtwarzacza szary prostokąt z komunikatem
  „Nie znaleziono filmu”, bez crasha.
- Nagłówek: tytuł nawigacji „W kawiarni” (inline), „Wstecz” systemowy, gdy ekran zostanie podłączony.
  Styl reszty ekranu z istniejących ekranów (`Theme.swift`: kolory `lingo*`, `PrimaryButtonStyle`,
  karta jak `continueCard`/`CategoryTile`, tło `lingoBackground`).
- Gałąź `video-lesson-screen` od `data-models-standardize` (nowe nazwy assetów są dopiero tam).

## Ograniczenia
- Brak Xcode na Windows: lokalnie testujemy tylko model (dekodowanie `data.json`, wybór napisu, odmiana);
  build SwiftUI — CI na PR (macOS) i Xcode użytkownika.
- Plakat `video-cafe-poster` (img-12) zostaje na razie nieużyty na ekranie (wymaganie „każdy obraz
  użyty” w PDF — wróci z wariantem 3).

## Zostawione budującemu
Dokładne odstępy i rozmiary czcionek (z istniejących ekranów), sposób obserwacji czasu odtwarzania.
