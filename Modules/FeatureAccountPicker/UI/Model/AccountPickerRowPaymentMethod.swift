// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension AccountPickerRow {

    public struct PaymentMethod: Equatable {

        // MARK: - Internal properties

        let id: AnyHashable
        var title: String
        var description: String
        var badgeView: Image?
        var badgeBackground: Color

        // MARK: - Init

        public init(
            id: AnyHashable,
            title: String,
            description: String,
            badgeView: Image?,
            badgeBackground: Color
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.badgeView = badgeView
            self.badgeBackground = badgeBackground
        }
    }
}