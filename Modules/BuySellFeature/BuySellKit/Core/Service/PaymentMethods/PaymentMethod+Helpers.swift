// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit

extension PaymentMethod {
    init?(currency: String, method: PaymentMethodsResponse.Method, supportedFiatCurrencies: [FiatCurrency]) {
        // Preferrably use the payment method's currency
        let rawCurrency = method.currency ?? currency
        guard let currency = FiatCurrency(code: rawCurrency) else {
            return nil
        }

        // Make sure the take exists
        guard let rawType = PaymentMethodPayloadType(rawValue: method.type) else {
            return nil
        }

        guard let methodType = MethodType(type: rawType,
                                          subTypes: method.subTypes,
                                          currency: currency,
                                          supportedFiatCurrencies: supportedFiatCurrencies) else {
            return nil
        }
        let min = FiatValue.create(minor: method.limits.min, currency: currency)!
        let max = FiatValue.create(minor: method.limits.max, currency: currency)!
        self.init(type: methodType, max: max, min: min, isEligible: method.eligible)
    }
}

extension PaymentMethod.MethodType {
    public var analyticsParameter: AnalyticsEvents.SimpleBuy.PaymentMethod {
        switch self {
        case .card:
            return .card
        case .bankAccount, .bankTransfer:
            return .bank
        case .funds:
            return .funds
        }
    }
}

extension Array where Element == PaymentMethod {
    init(response: PaymentMethodsResponse, supportedFiatCurrencies: [FiatCurrency]) {
        self.init()
        let methods = response.methods
            .compactMap {
                PaymentMethod(
                    currency: response.currency,
                    method: $0,
                    supportedFiatCurrencies: supportedFiatCurrencies
                )
            }
        append(contentsOf: methods)
    }

    init(methods: [PaymentMethodsResponse.Method], currency: FiatCurrency, supportedFiatCurrencies: [FiatCurrency]) {
        self.init()
        let methods = methods
            .compactMap {
                PaymentMethod(
                    currency: currency.code,
                    method: $0,
                    supportedFiatCurrencies: supportedFiatCurrencies
                )
            }
        append(contentsOf: methods)
    }

    public var funds: [PaymentMethod] {
        filter { $0.type.isFunds }
    }

    public var fundsCurrencies: [CurrencyType] {
        compactMap { method in
            switch method.type {
            case .funds(let currency):
                return currency
            default:
                return nil
            }
        }
    }
}
