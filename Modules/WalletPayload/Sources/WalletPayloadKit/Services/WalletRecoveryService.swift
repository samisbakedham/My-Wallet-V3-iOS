// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit
import WalletCore

public protocol WalletRecoveryServiceAPI {

    /// Recovers a wallet account using the given seed phrase (mnemonic)
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func recover(
        from seedPhrase: String
    ) -> AnyPublisher<EmptyValue, WalletError>
}

final class WalletRecoveryService: WalletRecoveryServiceAPI {

    private let walletHolder: WalletHolderAPI
    private let walletLogic: WalletLogicAPI

    init(
        walletHolder: WalletHolderAPI,
        walletLogic: WalletLogicAPI
    ) {
        self.walletHolder = walletHolder
        self.walletLogic = walletLogic
    }

    func recover(
        from seedPhrase: String
    ) -> AnyPublisher<EmptyValue, WalletError> {
        guard WalletCore.Mnemonic.isValid(mnemonic: seedPhrase) else {
            return .failure(.recovery(.invalidSeedPhrase))
        }
        return walletLogic
            .initialize(with: seedPhrase)
            .map { _ in .noValue }
            .eraseToAnyPublisher()
    }
}