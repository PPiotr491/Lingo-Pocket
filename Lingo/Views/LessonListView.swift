import SwiftUI

/// Ekran 03 – Lista lekcji w wybranej kategorii.
struct LessonListView: View {
    let category: Category

    var body: some View {
        // TODO - filtry poziomu, postęp i wiersze lekcji (ekran 03 z makiety)
        VStack(spacing: 8) {
            Text("Lekcje z kategorii „\(category.title)”")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.lingoTextPrimary)
            Text(category.lessonCountText)
                .font(.system(size: 15))
                .foregroundStyle(Color.lingoTextSecondary)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lingoBackground.ignoresSafeArea())
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct LessonTile: View {
//    let lesson: Lesson
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Color.clear
//                .frame(height: 112)
//                .overlay(
//                    Image(lesson.imageName)
//                        .resizable()
//                        .scaledToFill()
//                )
//                .clipped()
//                .accessibilityHidden(true)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(category.title)
//                    .font(.system(size: 17, weight: .semibold))
//                    .foregroundStyle(Color.lingoTextPrimary)
//                Text(category.lessonCountText)
//                    .font(.system(size: 13))
//                    .foregroundStyle(Color.lingoTextSecondary)
//            }
//            .padding(12)
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .background(Color.lingoSurface)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .lingoCardShadow()
//        .contentShape(RoundedRectangle(cornerRadius: 16))
//        .accessibilityElement(children: .combine)
//        .accessibilityAddTraits(.isButton)
//    }
//}

#Preview {
    NavigationStack {
        LessonListView(category: ContentViewModel().categories[0])
    }
}
