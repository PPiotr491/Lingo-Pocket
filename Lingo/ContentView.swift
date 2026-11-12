//
//  ContentView.swift
//  Lingo
//
//  Created by stud on 04/11/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var path: [Route] = []

    enum Route: Hashable {
        case home
    }

    var body: some View {
        NavigationStack(path: $path) {
            OnboardingView {
                path.append(.home)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .home:
                    // TODO: ekran 02 Home – do zaimplementowania w kolejnym kroku.
                    Text("Home")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
