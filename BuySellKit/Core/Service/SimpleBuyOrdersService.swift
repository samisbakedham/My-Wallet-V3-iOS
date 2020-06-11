//
//  SimpleBuyOrdersService.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol SimpleBuyOrdersServiceAPI: class {

    /// Streams all cached Simple Buy orders from cache, or fetch from
    /// remote if they are not cached
    var orders: Single<[SimpleBuyOrderDetails]> { get }
    
    /// Fetches the orders from remote
    func fetchOrders() -> Single<[SimpleBuyOrderDetails]>
    
    /// Fetches the order for a given identifier
    func fetchOrder(with identifier: String) -> Single<SimpleBuyOrderDetails>
}

public final class SimpleBuyOrdersService: SimpleBuyOrdersServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Exposed
    
    public var orders: Single<[SimpleBuyOrderDetails]> {
        ordersCachedValue.valueSingle
    }
    
    private let ordersCachedValue = CachedValue<[SimpleBuyOrderDetails]>(configuration: .onSubscriptionAndLogin)

    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording
    private let client: SimpleBuyOrderDetailsClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    private let reactiveWallet: ReactiveWalletAPI
    
    // MARK: - Setup
    
    public init(analyticsRecorder: AnalyticsEventRecording,
                client: SimpleBuyOrderDetailsClientAPI,
                reactiveWallet: ReactiveWalletAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.authenticationService = authenticationService
        
        ordersCachedValue.setFetch {
            reactiveWallet
                .waitUntilInitializedSingle
                .flatMap { _ in
                    authenticationService
                        .tokenString
                        .flatMap { client.orderDetails(token: $0, pendingOnly: false) }
                        .map { rawOrders in
                            rawOrders.compactMap {
                                SimpleBuyOrderDetails(recorder: analyticsRecorder, response: $0)
                            }
                        }
                }
        }
    }
    
    public func fetchOrders() -> Single<[SimpleBuyOrderDetails]> {
        ordersCachedValue.fetchValue
    }
    
    public func fetchOrder(with identifier: String) -> Single<SimpleBuyOrderDetails> {
        authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) in
                self.client.orderDetails(with: identifier, token: token)
            }
            .map(weak: self) { (self, response) in
                SimpleBuyOrderDetails(recorder: self.analyticsRecorder, response: response)
            }
            .map { details -> SimpleBuyOrderDetails in
                guard let details = details else {
                    throw ServiceError.mappingError
                }
                return details
            }
    }
}