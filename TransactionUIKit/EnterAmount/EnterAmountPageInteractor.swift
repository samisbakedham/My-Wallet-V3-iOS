//
//  EnterAmountPageInteractor.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import TransactionKit

protocol EnterAmountPageRouting: AnyObject {
    func showError()
}

protocol EnterAmountPageListener: AnyObject {
    func enterAmountDidTapBack()
    func closeFlow()
    func continueToKYCTiersScreen()
}

protocol EnterAmountPagePresentable: Presentable {
    var continueButtonTapped: Signal<Void> { get }
    func connect(state: Driver<EnterAmountPageInteractor.State>) -> Driver<EnterAmountPageInteractor.Effects>
}

final class EnterAmountPageInteractor: PresentableInteractor<EnterAmountPagePresentable>,
                                       EnterAmountPageInteractable {

    weak var router: EnterAmountPageRouting?
    weak var listener: EnterAmountPageListener?

    /// The interactor that `SendAuxililaryViewPresenter` uses
    private let auxiliaryViewInteractor: SendAuxililaryViewInteractor
    /// The interactor that `SingleAmountPreseneter` uses
    private let amountInteractor: AmountTranslationInteractor

    private let loadingViewPresenter: LoadingViewPresenting
    private let alertViewPresenter: AlertViewPresenterAPI
    private let priceService: PriceServiceAPI
    private let transactionModel: TransactionModel

    init(transactionModel: TransactionModel,
         presenter: EnterAmountPagePresentable,
         amountInteractor: AmountTranslationInteractor,
         loadingViewPresenter: LoadingViewPresenting = resolve(),
         alertViewPresenter: AlertViewPresenterAPI = resolve(),
         priceService: PriceServiceAPI = resolve()) {
        self.transactionModel = transactionModel
        self.amountInteractor = amountInteractor
        self.priceService = priceService
        self.auxiliaryViewInteractor = SendAuxililaryViewInteractor()
        self.alertViewPresenter = alertViewPresenter
        self.loadingViewPresenter = loadingViewPresenter
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let transactionState: Observable<TransactionState> = transactionModel
            .state
            .share(replay: 1, scope: .whileConnected)

        amountInteractor
            .amount
            .debounce(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap { (amount) -> Observable<MoneyValue> in
                transactionState
                    .take(1)
                    .asSingle()
                    .map { state in
                        if let fiat = amount.fiatValue, !state.allowFiatInput {
                            guard let sourceToFiatPair = state.sourceToFiatPair else {
                                return MoneyValue.zero(currency: amount.currency)
                            }
                            return MoneyValuePair(fiat: fiat,
                                                  priceInFiat: sourceToFiatPair.quote.fiatValue!,
                                                  cryptoCurrency: state.source!.asset,
                                                  usesFiatAsBase: true).quote
                        }
                        return amount
                    }
                    .asObservable()
            }
            .subscribe { [weak self] (amount: MoneyValue) in
                self?.transactionModel.process(action: .updateAmount(amount))
            }
            .disposeOnDeactivate(interactor: self)
        
        let spendable = transactionState
            .map { state in
                (
                    min: state.minSpendable.displayableRounding(roundingMode: .up),
                    max: state.maxSpendable.displayableRounding(roundingMode: .down),
                    errorState: state.errorState
                )
            }
            .share(scope: .whileConnected)
        
        auxiliaryViewInteractor
            .connect(stream: spendable.map(\.max))
            .disposeOnDeactivate(interactor: self)

        auxiliaryViewInteractor.resetToMaxAmount
            .withLatestFrom(spendable.map(\.max))
            .subscribe(onNext: { [weak self] maxSpendable in
                self?.amountInteractor.set(amount: maxSpendable)
            })
            .disposeOnDeactivate(interactor: self)
        
        spendable
            .map { [weak listener] spendable in
                spendable.errorState.toAmountInteractorState(min: spendable.min, max: spendable.max, listener: listener)
            }
            .bindAndCatch(to: amountInteractor.stateRelay)
            .disposeOnDeactivate(interactor: self)

        let interactorState = transactionModel.state
            .scan(initialState()) { (state, updater) -> State in
                let topSelection = TopSelectionState(
                    sourceAccount: updater.source,
                    destinationAccount: updater.destination as? BlockchainAccount
                )
                return state
                    .update(\.canContinue, value: updater.nextEnabled)
                    .update(\.topSelection, value: topSelection)
                    .update(\.topSelection.title,
                            value: try TransactionFlowDescriptor.EnterAmountScreen.headerTitle(state: updater))
                    .update(\.topSelection.subtitle,
                            value: try TransactionFlowDescriptor.EnterAmountScreen.headerSubtitle(state: updater))
            }
            .asDriverCatchError()

        presenter.continueButtonTapped
            .emit(weak: self) { (self, _) in
                self.transactionModel.process(action: .prepareTransaction)
            }
            .disposeOnDeactivate(interactor: self)

        presenter.connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func handle(effects: Effects) {
        switch effects {
        case .back:
            listener?.enterAmountDidTapBack()
        case .close:
            listener?.closeFlow()
        case .none:
            break
        }
    }
    
    private func initialState() -> State {
        let topSelectionState = TopSelectionState(sourceAccount: nil, destinationAccount: nil)
        let bottomAuxiliaryState = BottomAuxiliaryViewModelState.maxAvailable(
            SendAuxililaryViewPresenter(interactor: auxiliaryViewInteractor,
                                        availableBalanceTitle: TransactionFlowDescriptor.availableBalanceTitle,
                                        maxButtonTitle: TransactionFlowDescriptor.maxButtonTitle)
        )
        return State(
            topSelection: topSelectionState,
            bottomAuxiliaryState: bottomAuxiliaryState,
            canContinue: false
        )
    }
}

extension EnterAmountPageInteractor {
    struct State {
        var topSelection: TopSelectionState
        var bottomAuxiliaryState: BottomAuxiliaryViewModelState
        var canContinue: Bool
    }

    /// The state of the top selection view
    struct TopSelectionState {
        var title: String = ""
        var titleDescriptor: (font: UIFont, textColor: UIColor)
        var subtitle: String = ""
        var subtitleDescriptor: (font: UIFont, textColor: UIColor)
        let isEnabled: Bool = false
        var trailingContent: SelectionButtonViewModel.TrailingContent
        var leadingContent: SelectionButtonViewModel.LeadingContentType?
        var accessibilityContent: SelectionButtonViewModel.AccessibilityContent?

        private init(titleDescriptor: (font: UIFont, textColor: UIColor),
                     subtitleDescriptor: (font: UIFont, textColor: UIColor),
                     trailingContent: SelectionButtonViewModel.TrailingContent,
                     leadingContent: SelectionButtonViewModel.LeadingContentType?,
                     accessibilityContent: SelectionButtonViewModel.AccessibilityContent?) {
            self.titleDescriptor = titleDescriptor
            self.subtitleDescriptor = subtitleDescriptor
            self.trailingContent = trailingContent
            self.leadingContent = leadingContent
            self.accessibilityContent = accessibilityContent
        }

        init(sourceAccount: BlockchainAccount?, destinationAccount: BlockchainAccount?) {

            let transactionImageViewModel = TransactionDescriptorViewModel(
                sourceAccount: sourceAccount as? SingleAccount,
                destinationAccount: destinationAccount as? SingleAccount,
                assetAction: .swap
            )
            self.init(
                titleDescriptor: (font: .main(.medium, 12.0), textColor: .descriptionText),
                subtitleDescriptor: (font: .main(.semibold, 14.0), textColor: .titleText),
                trailingContent: .transaction(transactionImageViewModel),
                leadingContent: .none,
                accessibilityContent: nil
            )
        }
    }

    /// The state of the bottom auxiliary view
    enum BottomAuxiliaryViewModelState {
        /// Max available style button with available amount for spending and use-maximum button
        case maxAvailable(SendAuxililaryViewPresenter)

        /// Hidden - nothing to present
        case hidden
    }

}

extension EnterAmountPageInteractor {
    enum Effects {
        case back
        case close
        case none
    }
}

extension EnterAmountPageInteractor.State {
    func update<Value>(_ keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }
}

extension EnterAmountPageInteractor.BottomAuxiliaryViewModelState: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.hidden, .hidden):
            return true
        case (.maxAvailable, .maxAvailable):
            return true
        default:
            return false
        }
    }
}

extension TransactionErrorState {
    private typealias LocalizedString = LocalizationConstants.Transaction.Swap.KYC
    func toAmountInteractorState(min: MoneyValue, max:  MoneyValue, listener: EnterAmountPageListener?) -> AmountTranslationInteractor.State {
        switch self {
        case .none:
            return .inBounds
        case .overSilverTierLimit:
            return .warning(
                message: LocalizedString.overSilverLimitWarning,
                action: { [weak listener] in
                    listener?.continueToKYCTiersScreen()
                }
            )
        case .overGoldTierLimit,
             .overMaximumLimit,
             .insufficientFundsForFees,
             .insufficientFunds:
            return .maxLimitExceeded(max)
        case .belowMinimumLimit:
            return .minLimitExceeded(min)
        case .addressIsContract,
             .insufficientGas,
             .invalidAddress,
             .invalidAmount,
             .invalidPassword,
             .optionInvalid,
             .transactionInFlight,
             .pendingOrdersLimitReached,
             .unknownError:
            return .empty
        }
    }
}