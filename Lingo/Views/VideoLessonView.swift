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
    /// Token obserwatora czasu, potrzebny do jego usunięcia.
    @State private var timeObserver: Any?
    /// Bieżąca chwila filmu w sekundach (odświeżana co 0,1 s).
    @State private var currentTime: Double = 0
    /// Długość filmu wczytana z pliku; nil do czasu wczytania.
    @State private var videoDuration: Double?
    @State private var subtitleLanguage: SubtitleLanguage = .english

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
        .onAppear(perform: startObservingTime)
        .onDisappear(perform: stopPlayback)
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
                        caption: video.subtitle(at: currentTime, language: subtitleLanguage)
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

    /// Tworzy odtwarzacz (raz) i zaczyna śledzić czas co 0,1 s. Bez autoodtwarzania.
    private func startObservingTime() {
        guard let videoURL else { return }
        let activePlayer = player ?? AVPlayer(url: videoURL)
        if player == nil {
            player = activePlayer
        }
        guard timeObserver == nil else { return }

        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = activePlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let seconds = time.seconds
            // Obserwator działa na kolejce głównej, więc jesteśmy na MainActor.
            MainActor.assumeIsolated {
                currentTime = seconds
            }
        }
    }

    /// Po zejściu z ekranu: pauza i usunięcie obserwatora czasu.
    private func stopPlayback() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
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

/// Systemowy odtwarzacz Apple: obraz wypełnia ramkę, napis nałożony na obraz (widoczny też w pełnym ekranie).
private struct LessonVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer?
    let caption: String?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspectFill

        // Napis w contentOverlayView: między obrazem a kontrolkami, także w pełnym ekranie.
        let captionHost = UIHostingController(rootView: Caption(text: caption))
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

        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        if controller.player !== player {
            controller.player = player
        }
        context.coordinator.captionHost?.rootView = Caption(text: caption)
    }

    /// Trzyma kontroler napisu, żeby podmieniać jego treść przy każdej aktualizacji.
    final class Coordinator {
        var captionHost: UIHostingController<Caption>?
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
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
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
