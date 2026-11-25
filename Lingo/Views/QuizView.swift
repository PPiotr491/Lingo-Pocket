import SwiftUI
import AVFoundation

// Struktura pojedynczej opcji w quizie
struct QuizOption: Identifiable {
    let id = UUID()
    let word: String
    let translation: String
    let imageName: String
    let isCorrect: Bool
}

// Modyfikator realizujący efekt "shake"
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct QuizView: View {
    @State private var selectedOptionId: UUID? = nil
    @State private var isAnswered = false
    @State private var isCorrectAnswer = false
    @State private var shakeTrigger: CGFloat = 0
    @State private var audioPlayer: AVAudioPlayer?
    
    // Przykładowe dane pytania zgodnie z makietą (Ekran 06)
    let questionTerm = "cheese"
    let correctTranslation = "ser"
    let options: [QuizOption] = [
        QuizOption(word: "bread", translation: "chleb", imageName: "img-14", isCorrect: false),
        QuizOption(word: "cheese", translation: "ser", imageName: "img-13", isCorrect: true),
        QuizOption(word: "banana", translation: "banan", imageName: "img-15", isCorrect: false),
        QuizOption(word: "tomato", translation: "pomidor", imageName: "img-16", isCorrect: false)
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            
            // 1. Pasek postępu i licznik poprawnych odpowiedzi
            VStack(spacing: 8) {
                HStack {
                    Text("Pytanie 4 z 10")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(isAnswered && isCorrectAnswer ? "4 poprawne" : "3 poprawne")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "17794A"))                 }
                
                ProgressView(value: 0.4)
                    .tint(Color(hex: "2F5BEA"))
            }
            .padding(.horizontal)
            
            // 2. Pytanie główne
            VStack(spacing: 6) {
                Text("Który obrazek to „\(questionTerm)”?")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Dotknij właściwego zdjęcia")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
            
            // 3. Siatka 2x2 ze zdjęciami
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(options) { option in
                    let isSelected = selectedOptionId == option.id
                    
                    ZStack(alignment: .topTrailing) {
                        Image(option.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(borderColor(for: option, isSelected: isSelected), lineWidth: isSelected ? 4 : 0)
                            )
                        
                        // Ikona statusu w prawym górnym rogu wybranego kafelka
                        if isSelected {
                            Image(systemName: option.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(option.isCorrect ? Color(hex: "17794A") : Color(hex: "C62828"))
                                .background(Circle().fill(Color.white))
                                .padding(10)
                        }
                    }
                    // Sprężyna przy poprawnej odpowiedzi
                    .scaleEffect(isSelected && option.isCorrect ? 1.05 : 1.0)
                    // Efekt "shake" przy błędnej odpowiedzi
                    .modifier(ShakeEffect(animatableData: isSelected && !option.isCorrect ? shakeTrigger : 0))
                    .onTapGesture {
                        handleSelection(option)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 4. Baner informacji zwrotnej (wjeżdża od dołu)
            if isAnswered {
                HStack(spacing: 12) {
                    Image(systemName: isCorrectAnswer ? "checkmark" : "xmark")
                        .font(.headline)
                        .foregroundColor(isCorrectAnswer ? Color(hex: "17794A") : Color(hex: "C62828"))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isCorrectAnswer ? "Świetnie!" : "Prawie!")
                            .font(.headline)
                            .foregroundColor(isCorrectAnswer ? Color(hex: "17794A") : Color(hex: "C62828"))
                        
                        Text("\(questionTerm) = \(correctTranslation)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding()
                .background(isCorrectAnswer ? Color(hex: "17794A").opacity(0.12) : Color(hex: "C62828").opacity(0.12))
                .cornerRadius(12)
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // 5. Przycisk "Dalej"
            Button(action: {
                // Przejście do kolejnego pytania lub Ekranu 07 Profil
                print("Następne pytanie")
            }) {
                Text("Dalej")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAnswered ? Color(hex: "2F5BEA") : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!isAnswered)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(hex: "F5F7FC")) // Tło aplikacji z dokumentacji
        .navigationTitle("Quiz: Jedzenie")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar) // Ukrycie Tab Baru dla skupienia na zadaniu
    }
    
    private func borderColor(for option: QuizOption, isSelected: Bool) -> Color {
        guard isSelected else { return .clear }
        return option.isCorrect ? Color(hex: "17794A") : Color(hex: "C62828")
    }
    
    private func handleSelection(_ option: QuizOption) {
        guard !isAnswered else { return } // Blokada ponownego kliknięcia
        
        selectedOptionId = option.id
        isCorrectAnswer = option.isCorrect
        
        if option.isCorrect {
            playDingSound()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isAnswered = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.4)) {
                isAnswered = true
                shakeTrigger += 1
            }
        }
    }
    
    private func playDingSound() {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "m4a") else {
            print("Nie znaleziono pliku: ding.m4a")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Błąd odtwarzania dźwięku: \(error.localizedDescription)")
        }
    }
}

// Pomocnicze rozszerzenie dla kolorów HEX z dokumentacji
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    NavigationStack {
        QuizView()
    }
}
