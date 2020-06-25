//
//  AddressInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

final class AddressInteractor: AddressInteracting {
    
    /// The type of the asset coupled to the interactor
    let asset: CryptoCurrency
    
    /// The type of the subscribed address
    private let addressType: AssetAddressType
    
    // MARK: - Services
    
    /// PATCH: Don't change until ReactiveWallet is fixed. This is here because `ReactiveWallet` keeps checking if
    /// the wallet is initialized during the wallet creation - which generate a crash.
    private lazy var addressFetcher: AssetAddressFetching = addressFetcherProvider()
    private let addressFetcherProvider: () -> AssetAddressFetching
    private let addressSubscriber: AssetAddressSubscribing
    private let qrCodeGenerator: QRCodeGenerator
    private let recorder: ErrorRecording
    
    // MARK: - Rx

    private let disposeBag = DisposeBag()
    
    private let receivedPaymentRelay = PublishRelay<ReceivedPaymentDetails>()
    
    /// Streams any received payment that is coupled with the currently observed address
    var receivedPayment: Observable<ReceivedPaymentDetails> {
        receivedPaymentRelay.asObservable()
    }
    
    /// Fetches a new address from repo (for the asset coupled with `Self` instance) ->
    /// Verifies that the address hasn't been used in other transaction ->
    /// Subscribes to future payments made to that address ->
    /// Converts the address into a displayable format (Text + QR Image)
    /// - For efficiency sake, subscribe only on background scheduler
    var address: Single<WalletAddressContent> {
        addressSubscribedToPayments
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .map { [weak self] address -> WalletAddressContent in
                guard let self = self else {
                    throw AddressFetchingError.unretainedSelf
                }
                                
                // Create a url
                let qrUrl: String
                if let url = AssetURLPayloadFactory.create(fromString: address, asset: self.asset) {
                    qrUrl = url.address
                } else {
                    qrUrl = address
                }
                                                       
                // Generate a QR image out of the provided url
                guard let image = self.qrCodeGenerator.createQRImage(fromString: qrUrl) else {
                    let error = AddressFetchingError.parsing
                    self.recorder.error(error)
                    throw error
                }
                
                return WalletAddressContent(string: address, image: image)
            }
    }
    
    // Subscribes address to incoming payments using the wallet
    private var addressSubscribedToPayments: Single<String> {
        unusedAddress
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { [weak self] address in
                guard let self = self else { return }
                self.addressSubscriber.subscribe(to: address,
                                                 asset: self.asset,
                                                 addressType: self.addressType)
            })
    }
    
    // Retrive the status of the address (used, unused, unknown), validates it and map it to raw representation
    private var unusedAddress: Single<String> {
        fetchedAddress
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap(weak: self) { (self, address) -> Single<AddressUsageStatus> in
                self.addressFetcher.checkUsability(of: address, asset: self.asset)
            }
            .do(onSuccess: { [weak self] status in
                guard status.isUnused else {
                    self?.remove(address: status.address)
                    throw AddressFetchingError.alreadyUsed
                }
            })
            .map {
                $0.address
        }
    }
    
    // Get the address from address-repo
    private var fetchedAddress: Single<String> {
        .create { [weak self] single in
            guard let self = self else {
                single(.error(AddressFetchingError.unretainedSelf))
                return Disposables.create()
            }
            
            // Get a swipe to receive address
            guard let address = self.addressFetcher.addresses(by: self.addressType, asset: self.asset).first?.address else {
                let error = AddressFetchingError.absent
                self.recorder.error(error)
                single(.error(error))
                return Disposables.create()
            }
            single(.success(address))
            return Disposables.create()
        }
    }
    
    // MARK: - Setup
    
    init(asset: CryptoCurrency,
         addressType: AssetAddressType,
         addressFetcherProvider: @escaping () -> AssetAddressFetching = { AssetAddressRepository.shared },
         transactionObserver: TransactionObserving = WalletManager.shared,
         addressSubscriber: AssetAddressSubscribing = WalletManager.shared.wallet,
         qrCodeGenerator: QRCodeGenerator = QRCodeGenerator(),
         recorder: ErrorRecording = CrashlyticsRecorder()) {
        self.asset = asset
        self.addressType = addressType
        self.addressFetcherProvider = addressFetcherProvider
        self.addressSubscriber = addressSubscriber
        self.qrCodeGenerator = qrCodeGenerator
        self.recorder = recorder
        
        // Observe received payments for the associated asset.
        // Upon payment to that asset, removes the first swipe to receive address
        transactionObserver.paymentReceived
            .filter { [weak self] in
                $0.asset == self?.asset
            }
            .do(onNext: { [weak self] paymentDetails in
                self?.remove(address: paymentDetails.address)
            })
            .bind(to: receivedPaymentRelay)
            .disposed(by: disposeBag)
    }
    
    /// Removes used addresses if necessary
    private func remove(address: String) {
        guard !asset.shouldAddressesBeReused else {
            return
        }
        addressFetcher.remove(address: address, for: asset, addressType: addressType)
    }
}
