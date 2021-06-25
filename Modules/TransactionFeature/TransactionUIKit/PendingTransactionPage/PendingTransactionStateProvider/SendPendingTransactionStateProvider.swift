// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

final class SendPendingTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Send.Completion

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state
            .map(weak: self) { (self, state) in
                switch state.executionStatus {
                case .inProgress,
                     .notStarted:
                    return self.pending(state: state)
                case .completed:
                    return self.success(state: state)
                case .error:
                    return self.failed(state: state)
                }
            }
    }

    // MARK: - Private Functions

    private func success(state: TransactionState) -> PendingTransactionPageState {
        let amount = state.amount
        let asset = amount.currency
        let localImage = asset.logoResource.local
        return .init(
            title: String(
                format: LocalizationIds.Success.title,
                amount.displayString
            ),
            subtitle: String(
                format: LocalizationIds.Success.description,
                asset.name
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(localImage.name, localImage.bundle),
                    sideViewAttributes: .init(type: .image("v-success-icon"), position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .close,
            buttonViewModel: .primary(with: LocalizationConstants.okString)
        )
    }

    private func pending(state: TransactionState) -> PendingTransactionPageState {
        let sent = state.amount
        let logo = sent.currency.logoResource
        var title = String(
            format: LocalizationIds.Pending.title,
            sent.displayString
        )
        let zeroSent = MoneyValue.zero(currency: sent.currencyType)
        if sent == zeroSent {
            title = String(
                format: LocalizationIds.Pending.title,
                sent.displayCode
            )
        }
        return .init(
            title: title,
            subtitle: LocalizationIds.Pending.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(logo.local.name, logo.local.bundle),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            buttonViewModel: nil
        )
    }

    private func failed(state: TransactionState) -> PendingTransactionPageState {
        let currency = state.amount.currency
        let localImage = currency.logoResource.local
        return .init(
            title: state.transactionErrorDescription,
            subtitle: LocalizationIds.Failure.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(localImage.name, localImage.bundle),
                    sideViewAttributes: .init(type: .image("circular-error-icon"), position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .close,
            buttonViewModel: .primary(with: LocalizationConstants.okString)
        )
    }
}
