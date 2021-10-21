// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

/// An icon asset from the Component Library
///
/// See extension below for supported icons.
///
/// # Usage:
///
/// `Icon.activity.image`
///
/// # Figma
///
///  [Assets - Icons](https://www.figma.com/file/3jESURhHQ4VBTQcu0aZkoX/01---Assets-%7C-Icons)
public struct Icon {
    let name: String

    /// A SwiftUI Image View representing the given icon
    public var image: Image {
        Image(name, bundle: Bundle.componentLibrary)
    }
}

extension Icon {
    public static let activity = Icon(name: "Activity")
    public static let airdrop = Icon(name: "Airdrop")
    public static let alert = Icon(name: "Alert")
    public static let android = Icon(name: "Android")
    public static let apple = Icon(name: "Apple")
    public static let arrowRight = Icon(name: "Arrow Right")
    public static let arrowDown = Icon(name: "Arrow-Down")
    public static let arrowUp = Icon(name: "Arrow-Up")
    public static let backspaceAndroid = Icon(name: "Backspace Android")
    public static let backup = Icon(name: "Backup")
    public static let bank = Icon(name: "Bank")
    public static let blockchain = Icon(name: "Blockchain")
    public static let calendar = Icon(name: "Calendar")
    public static let call = Icon(name: "Call")
    public static let camera = Icon(name: "Camera")
    public static let cart = Icon(name: "Cart")
    public static let chartBar = Icon(name: "Chart Bar")
    public static let chartBubble = Icon(name: "Chart Bubble")
    public static let chartPie = Icon(name: "Chart Pie")
    public static let chat = Icon(name: "Chat")
    public static let checkCircle = Icon(name: "Check Circle")
    public static let check = Icon(name: "Check")
    public static let chevronDown = Icon(name: "Chevron-Down")
    public static let chevronLeft = Icon(name: "Chevron-Left")
    public static let chevronRight = Icon(name: "Chevron-Right")
    public static let chevronUp = Icon(name: "Chevron-Up")
    public static let clipboard = Icon(name: "Clipboard")
    public static let closeCirclev2 = Icon(name: "Close Circle v2")
    public static let closeCircle = Icon(name: "Close Circle")
    public static let closev2 = Icon(name: "Close v2")
    public static let close = Icon(name: "Close")
    public static let colorPicker = Icon(name: "Color Picker")
    public static let components = Icon(name: "Components")
    public static let computer = Icon(name: "Computer")
    public static let copy = Icon(name: "Copy")
    public static let creditcard = Icon(name: "Creditcard")
    public static let delete = Icon(name: "Delete")
    public static let deposit = Icon(name: "Deposit")
    public static let download = Icon(name: "Download")
    public static let edit = Icon(name: "Edit")
    public static let education = Icon(name: "Education")
    public static let email = Icon(name: "Email")
    public static let error = Icon(name: "Error")
    public static let exchange = Icon(name: "Exchange")
    public static let expandLess = Icon(name: "Expand Less")
    public static let expandMore = Icon(name: "Expand More")
    public static let explore = Icon(name: "Explore")
    public static let faceID = Icon(name: "Face ID")
    public static let favorite = Icon(name: "Favorite")
    public static let filter = Icon(name: "Filter")
    public static let fingerprint = Icon(name: "Fingerprint")
    public static let flag = Icon(name: "Flag")
    public static let flashOff = Icon(name: "Flash Off")
    public static let flashOn = Icon(name: "Flash On")
    public static let fullscreenExit = Icon(name: "Fullscreen Exit")
    public static let fullscreen = Icon(name: "Fullscreen")
    public static let globe = Icon(name: "Globe")
    public static let googleTranslate = Icon(name: "Google Translate")
    public static let hardware = Icon(name: "Hardware")
    public static let history = Icon(name: "History")
    public static let home = Icon(name: "Home")
    public static let identification = Icon(name: "Identification")
    public static let information = Icon(name: "Information")
    public static let interestCircle = Icon(name: "Interest Circle")
    public static let interest = Icon(name: "Interest")
    public static let key = Icon(name: "Key")
    public static let keyboard = Icon(name: "Keyboard")
    public static let laptop = Icon(name: "Laptop")
    public static let legal = Icon(name: "Legal")
    public static let lineChartUp = Icon(name: "Line Chart Up")
    public static let link = Icon(name: "Link")
    public static let listBullets = Icon(name: "List Bullets")
    public static let lockClosed = Icon(name: "Lock Closed")
    public static let lockOpen = Icon(name: "Lock Open")
    public static let logout = Icon(name: "Logout")
    public static let marketUp = Icon(name: "Market Up")
    public static let menu = Icon(name: "Menu")
    public static let microphone = Icon(name: "Microphone")
    public static let minusCircle = Icon(name: "Minus Circle")
    public static let moneyUSD = Icon(name: "Money USD")
    public static let moreHorizontal = Icon(name: "More Horizontal")
    public static let moreVertical = Icon(name: "More Vertical")
    public static let newWindow = Icon(name: "New Window")
    public static let notificationOff = Icon(name: "Notification Off")
    public static let notificationOn = Icon(name: "Notification On")
    public static let paperclip = Icon(name: "Paperclip")
    public static let pending = Icon(name: "Pending")
    public static let people = Icon(name: "People")
    public static let phone = Icon(name: "Phone")
    public static let placeholder = Icon(name: "Placeholder")
    public static let playCircle = Icon(name: "Play Circle")
    public static let plusCircle = Icon(name: "Plus Circle")
    public static let plus = Icon(name: "Plus")
    public static let portfolio = Icon(name: "Portfolio")
    public static let present = Icon(name: "Present")
    public static let print = Icon(name: "Print")
    public static let `private` = Icon(name: "Private")
    public static let qRCode = Icon(name: "QR Code")
    public static let questionCircle = Icon(name: "Question Circle")
    public static let question = Icon(name: "Question")
    public static let receive = Icon(name: "Receive")
    public static let refresh = Icon(name: "Refresh")
    public static let `repeat` = Icon(name: "Repeat")
    public static let search = Icon(name: "Search")
    public static let sell = Icon(name: "Sell")
    public static let send = Icon(name: "Send")
    public static let settings = Icon(name: "Settings")
    public static let shareAndroid = Icon(name: "Share Android")
    public static let shareiOS = Icon(name: "Share iOS")
    public static let shield = Icon(name: "Shield")
    public static let signout = Icon(name: "Signout")
    public static let subdirectory = Icon(name: "Subdirectory")
    public static let support = Icon(name: "Support")
    public static let swap = Icon(name: "Swap")
    public static let sync = Icon(name: "Sync")
    public static let tag = Icon(name: "Tag")
    public static let timeout = Icon(name: "Timeout")
    public static let tor = Icon(name: "Tor")
    public static let trade = Icon(name: "Trade")
    public static let unfoldLess = Icon(name: "Unfold Less")
    public static let unfoldMore = Icon(name: "Unfold More")
    public static let userAdd = Icon(name: "User Add")
    public static let user = Icon(name: "User")
    public static let verified = Icon(name: "Verified")
    public static let visibilityOff = Icon(name: "Visibility Off")
    public static let visibilityOn = Icon(name: "Visibility On")
    public static let wallet = Icon(name: "Wallet")
    public static let withdraw = Icon(name: "Withdraw")
}

struct Icon_Previews: PreviewProvider {
    static let allIcons: [Icon] = [
        .activity,
        .airdrop,
        .alert,
        .android,
        .apple,
        .arrowRight,
        .arrowDown,
        .arrowUp,
        .backspaceAndroid,
        .backup,
        .bank,
        .blockchain,
        .calendar,
        .call,
        .camera,
        .cart,
        .chartBar,
        .chartBubble,
        .chartPie,
        .chat,
        .checkCircle,
        .check,
        .chevronDown,
        .chevronLeft,
        .chevronRight,
        .chevronUp,
        .clipboard,
        .closeCirclev2,
        .closeCircle,
        .closev2,
        .close,
        .colorPicker,
        .components,
        .computer,
        .copy,
        .creditcard,
        .delete,
        .deposit,
        .download,
        .edit,
        .education,
        .email,
        .error,
        .exchange,
        .expandLess,
        .expandMore,
        .explore,
        .faceID,
        .favorite,
        .filter,
        .fingerprint,
        .flag,
        .flashOff,
        .flashOn,
        .fullscreenExit,
        .fullscreen,
        .globe,
        .googleTranslate,
        .hardware,
        .history,
        .home,
        .identification,
        .information,
        .interestCircle,
        .interest,
        .key,
        .keyboard,
        .laptop,
        .legal,
        .lineChartUp,
        .link,
        .listBullets,
        .lockClosed,
        .lockOpen,
        .logout,
        .marketUp,
        .menu,
        .microphone,
        .minusCircle,
        .moneyUSD,
        .moreHorizontal,
        .moreVertical,
        .newWindow,
        .notificationOff,
        .notificationOn,
        .paperclip,
        .pending,
        .people,
        .phone,
        .placeholder,
        .playCircle,
        .plusCircle,
        .plus,
        .portfolio,
        .present,
        .print,
        .private,
        .qRCode,
        .questionCircle,
        .question,
        .receive,
        .refresh,
        .repeat,
        .search,
        .sell,
        .send,
        .settings,
        .shareAndroid,
        .shareiOS,
        .shield,
        .signout,
        .subdirectory,
        .support,
        .swap,
        .sync,
        .tag,
        .timeout,
        .tor,
        .trade,
        .unfoldLess,
        .unfoldMore,
        .userAdd,
        .user,
        .verified,
        .visibilityOff,
        .visibilityOn,
        .wallet,
        .withdraw
    ]

    static let columns = Array(
        repeating: GridItem(.fixed(110)),
        count: 3
    )

    static var previews: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 48) {
            ForEach(allIcons, id: \.name) { icon in
                VStack {
                    icon.image
                    Text(icon.name)
                        .typography(.caption2)
                }
            }
        }
        .previewLayout(.sizeThatFits)
    }
}