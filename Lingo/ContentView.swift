//
//  ContentView.swift
//  Lingo
//
//  Created by stud on 04/11/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var path: [Route] = []
    @State private var viewModel = ContentViewModel()

    enum Route: Hashable {
        case home
        case lessons(Category)
    }

    var body: some View {
        NavigationStack(path: $path) {
            OnboardingView {
                path.append(.home)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .home:
                    HomeView(categories: viewModel.categories)
                case .lessons(let category):
                    LessonListView(category: category)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
