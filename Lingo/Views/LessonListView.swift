import SwiftUI

/// Ekran 03 – Lista lekcji w wybranej kategorii.
struct LessonListView: View {
    let category: CategoryView

    var body: some View {
        // TODO - filtry poziomu, postęp i wiersze lekcji (ekran 03 z makiety)
        VStack(spacing: 8) {
            Text("Lekcje z kategorii „\(category.name)”")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.lingoTextPrimary)
            Text(category.lessonCountText)
                .font(.system(size: 15))
                .foregroundStyle(Color.lingoTextSecondary)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lingoBackground.ignoresSafeArea())
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LessonListView(category: CategoryView.samples[0])
    }
}
