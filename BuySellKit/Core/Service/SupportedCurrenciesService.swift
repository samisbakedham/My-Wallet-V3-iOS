//
//  SupportedCurrenciesService.swift
//  PlatformKit
//
//  Created by Paulo on 01/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import ToolKit

public protocol SupportedCurrenciesServiceAPI: class {
    var valueObservable: Observable<Set<FiatCurrency>> { get }
    var valueSingle: Single<Set<FiatCurrency>> { get }
    func fetch() -> Observable<Set<FiatCurrency>>
}

final class SupportedCurrenciesService: SupportedCurrenciesServiceAPI {

    // MARK: - Public properties

    var valueObservable: Observable<Set<FiatCurrency>> {
        cachedValue.valueObservable
    }

    var valueSingle: Single<Set<FiatCurrency>> {
        cachedValue.valueSingle
    }

    // MARK: - Private properties

    private let cachedValue: CachedValue<Set<FiatCurrency>>

    // MARK: - Setup

    init(featureFetcher: FeatureFetching,
         pairsService: SupportedPairsServiceAPI,
         fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI) {

        cachedValue = .init(
            configuration: .init(
                identifier: "simple-buy-supported-currencies",
                refreshType: .onSubscription,
                fetchPriority: .fetchAll,
                flushNotificationName: .logout,
                fetchNotificationName: .login)
        )

        cachedValue
            .setFetch { () -> Single<Set<FiatCurrency>> in
                featureFetcher
                    .fetchBool(for: .simpleBuyEnabled)
                    .flatMap { isFeatureEnabled -> Single<Set<FiatCurrency>> in
                        guard isFeatureEnabled else {
                            return .just([])
                        }
                        return pairsService
                            .fetchPairs(for: .all)
                            .map { $0.fiatCurrencySet }
                    }
            }
    }

    func fetch() -> Observable<Set<FiatCurrency>> {
        cachedValue.fetchValueObservable
    }
}
