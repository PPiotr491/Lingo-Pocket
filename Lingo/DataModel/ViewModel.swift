import SwiftUI
import Observation

@Observable
final class ContentViewModel {
    // @Observable aby widok sam sie odswiezyl po zaladowaniu danych
    var categories: [Category] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            print("Nie znaleziono pliku data.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.categories = try decoder.decode([Category].self, from: data)
            print("Pomyślnie załadowano dane")
        } catch {
            print("Błąd podczas ładowania JSON: \(error)")
        }
    }
}
