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
                    Text("Home")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
