import SwiftUI
import AVKit
import AVFoundation

/// Ekran 05 – Lekcja wideo z napisami EN / PL.
struct VideoLessonView: View {
    let lesson: Lesson

    /// Adres filmu w paczce aplikacji; nil, gdy lekcja nie ma filmu albo pliku brak.
    private let videoURL: URL?

    /// Odtwarzacz tworzony raz na ekran (przy pierwszym pojawieniu się).
    @State private var player: AVPlayer?
    /// Długość filmu wczytana z pliku; nil do czasu wczytania.
    @State private var videoDuration: Double?
    @State private var subtitleLanguage: SubtitleLanguage = .english
    /// Czy odtwarzacz jest w pełnym ekranie (ustawia delegat odtwarzacza).
    @State private var fullScreen = PlayerFullScreenState()

    init(lesson: Lesson) {
        self.lesson = lesson
        if let video = lesson.video {
            videoURL = Bundle.main.url(forResource: video.fileName, withExtension: "mp4")
        } else {
            videoURL = nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let video = lesson.video {
                    videoFrame(for: video)
                    lessonHeader(for: video)
                    SubtitlePicker(selection: $subtitleLanguage)
                    descriptionCard(for: video)
                } else {
                    messageFrame("Ta lekcja nie ma jeszcze wideo.")
                }

                // Akcja zostanie podpięta, gdy powstanie ekran quizu.
                Button("Przejdź do quizu") {}
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lingoBackground.ignoresSafeArea())
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: preparePlayer)
        .onDisappear(perform: pausePlayback)
        .task { await loadVideoDuration() }
    }

    /// Ramka 16:9: odtwarzacz z napisem albo komunikat o braku pliku.
    @ViewBuilder
    private func videoFrame(for video: VideoContent) -> some View {
        if videoURL != nil {
            Color.clear
                .aspectRatio(16 / 9, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .overlay {
                    LessonVideoPlayer(
                        player: player,
                        video: video,
                        language: subtitleLanguage,
                        fullScreen: fullScreen
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            messageFrame("Nie znaleziono filmu.")
        }
    }

    /// Zastępcza ramka 16:9 z komunikatem na środku.
    private func messageFrame(_ message: String) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.lingoAccentSoft)
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .overlay {
                Text(message)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.lingoTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(16)
            }
    }

    private func lessonHeader(for video: VideoContent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(video.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.lingoTextPrimary)
            Text(metadataText)
                .font(.system(size: 15))
                .foregroundStyle(Color.lingoTextSecondary)
        }
    }

    /// „Poziom A1 · 0:10 min · 3 nowe słówka”; do czasu wczytania długości sam poziom.
    private var metadataText: String {
        var parts = ["Poziom \(lesson.level)"]
        if let videoDuration {
            parts.append("\(formattedVideoDuration(videoDuration)) min")
            if let newWords = lesson.newWordsText {
                parts.append(newWords)
            }
        }
        return parts.joined(separator: " · ")
    }

    private func descriptionCard(for video: VideoContent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Opis lekcji")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.lingoTextPrimary)
            Text(video.description)
                .font(.system(size: 15))
                .foregroundStyle(Color.lingoTextSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lingoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .lingoCardShadow()
    }

    // MARK: - Odtwarzanie

    /// Tworzy odtwarzacz (raz). Bez autoodtwarzania; napisy śledzi koordynator odtwarzacza.
    private func preparePlayer() {
        guard player == nil, let videoURL else { return }
        player = AVPlayer(url: videoURL)
    }

    /// Po zejściu z ekranu: pauza. Obserwator czasu usuwa koordynator przy rozbiórce odtwarzacza.
    private func pausePlayback() {
        // Pełny ekran zasłania ekran lekcji i może wywołać onDisappear, ale to nie jest wyjście z ekranu.
        guard !fullScreen.isActive else { return }
        player?.pause()
    }

    /// Wczytuje długość filmu z pliku; nieznana lub nieskończona długość zostaje pominięta.
    private func loadVideoDuration() async {
        guard videoDuration == nil, let videoURL else { return }
        let asset: AVAsset = AVURLAsset(url: videoURL)
        guard let duration = try? await asset.load(.duration) else { return }
        let seconds = duration.seconds
        if seconds.isFinite && seconds > 0 {
            videoDuration = seconds
        }
    }
}

/// Stan pełnego ekranu współdzielony przez ekran i delegata odtwarzacza (zmiana nie przerysowuje widoku).
private final class PlayerFullScreenState {
    var isActive = false
}

/// Systemowy odtwarzacz Apple: obraz wypełnia ramkę, napis nałożony na obraz (widoczny też w pełnym ekranie).
private struct LessonVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer?
    let video: VideoContent
    let language: SubtitleLanguage
    let fullScreen: PlayerFullScreenState

    func makeCoordinator() -> Coordinator {
        Coordinator(fullScreen: fullScreen, video: video, language: language)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspectFill
        controller.delegate = context.coordinator

        // Napis w contentOverlayView: między obrazem a kontrolkami, także w pełnym ekranie.
        let captionHost = UIHostingController(rootView: Caption(text: nil))
        captionHost.view.backgroundColor = .clear
        captionHost.view.isUserInteractionEnabled = false
        captionHost.view.translatesAutoresizingMaskIntoConstraints = false
        if let overlay = controller.contentOverlayView {
            overlay.addSubview(captionHost.view)
            NSLayoutConstraint.activate([
                captionHost.view.leadingAnchor.constraint(equalTo: overlay.leadingAnchor),
                captionHost.view.trailingAnchor.constraint(equalTo: overlay.trailingAnchor),
                captionHost.view.topAnchor.constraint(equalTo: overlay.topAnchor),
                captionHost.view.bottomAnchor.constraint(equalTo: overlay.bottomAnchor)
            ])
        }
        context.coordinator.captionHost = captionHost
        context.coordinator.observe(player)
        context.coordinator.refreshCaption()

        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        if controller.player !== player {
            controller.player = player
        }
        let coordinator = context.coordinator
        coordinator.video = video
        coordinator.language = language
        coordinator.observe(player)
        // Zmiana języka od razu, także w pauzie.
        coordinator.refreshCaption()
    }

    static func dismantleUIViewController(_ controller: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.stopObserving()
    }

    /// Prowadzi napis według czasu odtwarzacza (niezależnie od odświeżania ekranu, więc też w pełnym ekranie)
    /// i śledzi pełny ekran jako delegat odtwarzacza.
    final class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        var captionHost: UIHostingController<Caption>?
        let fullScreen: PlayerFullScreenState
        var video: VideoContent
        var language: SubtitleLanguage

        /// Odtwarzacz, na którym wisi obserwator; potrzebny do usunięcia obserwatora.
        private var observedPlayer: AVPlayer?
        private var timeObserver: Any?

        init(fullScreen: PlayerFullScreenState, video: VideoContent, language: SubtitleLanguage) {
            self.fullScreen = fullScreen
            self.video = video
            self.language = language
            super.init()
        }

        /// Obserwuje czas podanego odtwarzacza co 0,1 s; przy zmianie odtwarzacza zdejmuje stary obserwator.
        func observe(_ player: AVPlayer?) {
            guard player !== observedPlayer else { return }
            stopObserving()
            guard let player else { return }

            observedPlayer = player
            let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard let self else { return }
                let seconds = time.seconds
                // Obserwator działa na kolejce głównej, więc jesteśmy na MainActor.
                MainActor.assumeIsolated {
                    self.showCaption(at: seconds)
                }
            }
        }

        func stopObserving() {
            if let observer = timeObserver {
                observedPlayer?.removeTimeObserver(observer)
            }
            timeObserver = nil
            observedPlayer = nil
        }

        /// Napis dla bieżącej chwili odtwarzacza (np. po zmianie języka w pauzie).
        func refreshCaption() {
            showCaption(at: observedPlayer?.currentTime().seconds ?? 0)
        }

        /// Podmienia napis tylko przy zmianie kwestii; przenikanie 0,2 s robi widok `Caption`.
        private func showCaption(at seconds: Double) {
            let text = seconds.isFinite ? video.subtitle(at: seconds, language: language) : nil
            guard let captionHost, captionHost.rootView.text != text else { return }
            captionHost.rootView = Caption(text: text)
        }

        // Pełny ekran od początku przejścia; przerwane przejście cofa stan.
        nonisolated func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willBeginFullScreenPresentationWithAnimationCoordinator coordinator: any UIViewControllerTransitionCoordinator
        ) {
            // Delegat jest wywoływany na wątku głównym.
            MainActor.assumeIsolated {
                let fullScreen = self.fullScreen
                fullScreen.isActive = true
                _ = coordinator.animate(alongsideTransition: nil) { context in
                    if context.isCancelled {
                        fullScreen.isActive = false
                    }
                }
            }
        }

        // Koniec pełnego ekranu dopiero po zakończonym przejściu; przerwane zostawia pełny ekran.
        nonisolated func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willEndFullScreenPresentationWithAnimationCoordinator coordinator: any UIViewControllerTransitionCoordinator
        ) {
            // Delegat jest wywoływany na wątku głównym.
            MainActor.assumeIsolated {
                let fullScreen = self.fullScreen
                _ = coordinator.animate(alongsideTransition: nil) { context in
                    if !context.isCancelled {
                        fullScreen.isActive = false
                    }
                }
            }
        }
    }

    /// Napis przy dolnej krawędzi obrazu; zmiana kwestii z przenikaniem 0,2 s.
    struct Caption: View {
        let text: String?

        var body: some View {
            ZStack(alignment: .bottom) {
                if let text {
                    Text(text)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.lingoCaptionBackground, in: RoundedRectangle(cornerRadius: 8))
                        .id(text)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .animation(.easeInOut(duration: 0.2), value: text)
        }
    }
}

/// Przełącznik napisów: „Napisy:” i pigułki EN / PL / Wyłącz.
private struct SubtitlePicker: View {
    @Binding var selection: SubtitleLanguage

    var body: some View {
        HStack(spacing: 8) {
            Text("Napisy:")
                .font(.system(size: 15))
                .foregroundStyle(Color.lingoTextSecondary)

            ForEach(SubtitleLanguage.allCases, id: \.self) { language in
                let isSelected = language == selection
                Button {
                    selection = language
                } label: {
                    Text(language.label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.white : Color.lingoAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.lingoAccent : Color.lingoAccentSoft, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(language.accessibilityName)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

private extension SubtitleLanguage {
    /// Pełna nazwa dla VoiceOver zamiast skrótu z pigułki.
    var accessibilityName: String {
        switch self {
        case .english: return "Napisy angielskie"
        case .polish: return "Napisy polskie"
        case .off: return "Napisy wyłączone"
        }
    }
}

#Preview {
    NavigationStack {
        if let lesson = ContentViewModel().categories
            .flatMap(\.lessons)
            .first(where: { $0.id == "les_2" }) {
            VideoLessonView(lesson: lesson)
        }
    }
}
