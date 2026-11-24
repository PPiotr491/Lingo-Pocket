import SwiftUI
import AVFoundation

struct FlashcardsView: View {
    @State private var isFlipped = false
    @State private var audioPlayer: AVAudioPlayer?
    
    let currentWord: Word
    
    var body: some View {
        VStack(spacing: 30) {
            
            // 1. Górny pasek
            HStack {
                Text("Fiszki: Jedzenie")
                    .font(.headline)
                Spacer()
                Text("38%")
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // 2. Interaktywna Karta z animacją 3D
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.lingoCardShadow.opacity(0.8), radius: 10, x: 0, y: 5)
                
                if isFlipped {
                    Text(currentWord.translation)
                        .font(.largeTitle)
                        .bold()
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else {
                    VStack {
                        // Docelowe ładowanie obrazu
                        Image(currentWord.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding()
                        
                        Text(currentWord.englishTerm)
                            .font(.largeTitle)
                            .bold()
                        
                        Text(currentWord.transcription)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("↻ Dotknij, aby obrócić i zobaczyć tłumaczenie")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom)
                    }
                }
            }
            .frame(height: 400)
            .padding(.horizontal, 20)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isFlipped.toggle()
                }
            }
            
            // 3. Pełna implementacja odtwarzacza Audio
            Button(action: playAudio) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // 4. Dolne przyciski
            HStack(spacing: 20) {
                Button(action: { /* Logika przejścia do kolejnego słowa */ }) {
                    Text("Nie znam")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
                
                Button(action: { /* Logika przejścia do kolejnego słowa */ }) {
                    Text("Znam")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }.background(Color.lingoBackground)
    }
    
    private func playAudio() {
        guard let url = Bundle.main.url(forResource: currentWord.audioName, withExtension: "m4a") else {
            print("Nie znaleziono pliku: \(currentWord.audioName).m4a")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Błąd odtwarzania audio: \(error.localizedDescription)")
        }
    }
}

#Preview {
    FlashcardsView(currentWord: Word(id: "test_1", englishTerm: "apple", transcription: "/ˈæp.əl/", translation: "jabłko", imageName: "word-apple", audioName: "apple"))
}
