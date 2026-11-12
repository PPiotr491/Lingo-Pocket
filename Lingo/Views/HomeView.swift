//
//  HomeView.swift
//  Lingo
//
//  Created by stud on 12/11/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        HStack(spacing: 10) {
            VStack(spacing: 5) {
                Text("Cześć, **Username**")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.lingoTextPrimary)
                
                Text("Kontynuuj naukę języka")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.lingoTextSecondary)
            }
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 0) {
                Image("streakImg")
                    .resizable().scaledToFit().frame(height: 50)
                
                // TODO - zmienna na dni
                Text("x dni")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.lingoTextPrimary)
            }.backgroundStyle(Color.lingoBackground)
        }.frame(width: 350)
    }
}

#Preview {
    HomeView()
}
