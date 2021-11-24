//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureQRCodeScannerUI
import FeatureTransactionUI
import Localization
import PlatformUIKit
import SwiftUI

struct QRCodeScannerView: UIViewControllerRepresentable {

    var secureChannelRouter: SecureChannelRouting = resolve()

    private var send: (router: SendRootRouting, p2: UIViewController) = {
        let router = SendRootBuilder().build()
        let viewController = router.viewControllable.uiviewController
        router.interactable.activate()
        router.load()
        return (router, viewController)
    }()

    func makeUIViewController(context: Context) -> some UIViewController {

        let builder = QRCodeScannerViewControllerBuilder(
            completed: { result in
                guard case .success(let success) = result else {
                    return
                }

                switch success {
                case .secureChannel(let message):
                    self.secureChannelRouter.didScanPairingQRCode(msg: message)
                case .cryptoTarget(let target):
                    switch target {
                    case .address(let account, let address):
                        self.send.router.routeToSend(sourceAccount: account, destination: address)
                    case .bitpay:
                        break
                    }
                case .walletConnect:
                    break
                case .deepLink:
                    break
                }
            }
        )

        guard let viewController = builder.build() else {
            return UIHostingController(
                rootView: ActionableView(
                    .init(
                        media: .image(named: "circular-error-icon"),
                        title: LocalizationConstants.noCameraAccessTitle,
                        subtitle: LocalizationConstants.noCameraAccessMessage
                    ),
                    in: .platformUIKit
                )
            ) as UIViewController
        }

        return viewController as UIViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
