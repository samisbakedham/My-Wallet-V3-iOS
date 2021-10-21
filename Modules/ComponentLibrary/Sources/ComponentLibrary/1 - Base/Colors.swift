// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Colors from the Figma Component Library.
///
///
/// # Usage:
///
/// `Text("Hello World!").foregroundColor(Color.Semantic.title)`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Colors](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=352%3A8610)

extension Color {

    static func dynamicColor(light: Color, dark: Color) -> Color {
        Color(
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
            }
        )
    }

    public enum Semantic {

        public static let white: Color = Palette.white.color()

        public static let black: Color = Palette.black.color()

        public static let primary: Color = Palette.blue600.color()

        public static let primaryMuted: Color = Palette.blue400.color()

        public static let success: Color = Palette.green600.color()

        public static let successMuted: Color = Palette.green400.color()

        public static let warning: Color = Palette.warning.color()

        public static let warningMuted: Color = Palette.warningMuted.color()

        public static let error: Color = Palette.red600.color()

        public static let errorMuted: Color = Palette.red400.color()

        public static let title: Color = Palette.grey900.color()

        public static let body: Color = Palette.grey800.color()

        public static let muted: Color = Palette.grey400.color()

        public static let dark: Color = Palette.grey300.color()

        public static let medium: Color = Palette.grey100.color()

        public static let light: Color = Palette.grey000.color()
    }
}

extension Color.Semantic {

    private enum Palette: String {
        // base
        case white
        case black
        case warning
        case warningMuted
        // dark
        case dark000
        case dark100
        case dark200
        case dark300
        case dark400
        case dark500
        case dark600
        case dark700
        case dark800
        case dark900
        // grey
        case grey000
        case grey100
        case grey200
        case grey300
        case grey400
        case grey500
        case grey600
        case grey700
        case grey800
        case grey900
        // blue
        case blue000
        case blue400
        case blue600
        // green
        case green000
        case green400
        case green600
        // red
        case red000
        case red400
        case red600
        // orange
        case orange000
        case orange400
        case orange600
        // tiers
        case silver
        case gold

        func color() -> SwiftUI.Color {
            SwiftUI.Color(rawValue, bundle: Bundle.componentLibrary)
        }
    }
}

struct Colors_Previews: PreviewProvider {

    struct ColorMap: Identifiable {
        let color: Color
        let name: String
        var id: String { name }
    }

    static let allColors: [ColorMap] = [
        ColorMap(color: Color.Semantic.white, name: "white"),
        ColorMap(color: Color.Semantic.black, name: "black"),
        ColorMap(color: Color.Semantic.primary, name: "primary"),
        ColorMap(color: Color.Semantic.primaryMuted, name: "primaryMuted"),
        ColorMap(color: Color.Semantic.success, name: "success"),
        ColorMap(color: Color.Semantic.successMuted, name: "successMuted"),
        ColorMap(color: Color.Semantic.warning, name: "warning"),
        ColorMap(color: Color.Semantic.warningMuted, name: "warningMuted"),
        ColorMap(color: Color.Semantic.error, name: "error"),
        ColorMap(color: Color.Semantic.errorMuted, name: "errorMuted"),
        ColorMap(color: Color.Semantic.title, name: "title"),
        ColorMap(color: Color.Semantic.body, name: "body"),
        ColorMap(color: Color.Semantic.muted, name: "muted"),
        ColorMap(color: Color.Semantic.dark, name: "dark"),
        ColorMap(color: Color.Semantic.medium, name: "medium"),
        ColorMap(color: Color.Semantic.light, name: "light")
    ]

    static var previews: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                ForEach(allColors) {
                    swatch(color: $0.color, name: $0.name)
                }
            }
            .padding(12)
        }
    }

    @ViewBuilder static func swatch(color: Color, name: String) -> some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(height: 120)
            Text(name)
                .lineLimit(1)
                .padding()
                .truncationMode(.tail)
                .foregroundColor(Color.dynamicColor(light: Color.Semantic.title, dark: Color.Semantic.light))
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.dynamicColor(light: Color.Semantic.black, dark: Color.Semantic.white), lineWidth: 0.5)
        )
    }
}
