// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureKYCDomain
import FeatureTransactionDomain
import PlatformKit
import RxSwift
import ToolKit

public class ReceiveCoordinator {

    // MARK: - Types

    private enum ReceiveAction {
        case presentReceiveScreen(account: BlockchainAccount)
        case presentKYCScreen
        case presentError
    }

    // MARK: - Public Properties

    public let builder: ReceiveBuilder

    // MARK: - Private Properties

    private let coincore: CoincoreAPI
    private let receiveRouter: ReceiveRouterAPI
    private let kycStatusChecker: KYCStatusChecking
    private let analyticsHook: TransactionAnalyticsHook
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        coincore: CoincoreAPI = resolve(),
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        receiveRouter: ReceiveRouterAPI = resolve(),
        receiveSelectionService: AccountSelectionServiceAPI = AccountSelectionService(),
        kycStatusChecker: KYCStatusChecking = resolve(),
        analyticsHook: TransactionAnalyticsHook = resolve()
    ) {
        self.coincore = coincore
        self.receiveRouter = receiveRouter
        self.kycStatusChecker = kycStatusChecker
        self.analyticsHook = analyticsHook
        builder = ReceiveBuilder(
            internalFeatureFlagService: internalFeatureFlagService,
            receiveSelectionService: receiveSelectionService
        )

        receiveSelectionService
            .selectedData
            .flatMapLatest(weak: self) { (self, account) -> Observable<ReceiveAction> in
                switch account {
                case let account as ReceivePlaceholderCryptoAccount:
                    return self.present(placeholderAccount: account)
                case is TradingAccount:
                    return self.didSelectTradingAccountForReceive(account: account)
                default:
                    return .just(.presentReceiveScreen(account: account))
                }
            }
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .presentReceiveScreen(let account):
                    self?.receiveRouter.presentReceiveScreen(for: account)
                    if let account = account as? CryptoAccount {
                        self?.analyticsHook.onFromAccountSelected(account, action: .receive)
                    }
                case .presentKYCScreen:
                    self?.receiveRouter.presentKYCScreen()
                case .presentError:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods

    private func present(placeholderAccount: ReceivePlaceholderCryptoAccount) -> Observable<ReceiveAction> {
        coincore[placeholderAccount.asset]
            .defaultAccount
            .asObservable()
            .map { .presentReceiveScreen(account: $0) }
    }

    private func didSelectTradingAccountForReceive(account: BlockchainAccount) -> Observable<ReceiveAction> {
        kycStatusChecker.checkStatus()
            .map { status -> ReceiveAction in
                switch status {
                case .unverified, .verifying:
                    return .presentKYCScreen
                case .verified:
                    return .presentReceiveScreen(account: account)
                case .failed:
                    return .presentError
                }
            }
            .asObservable()
    }
}