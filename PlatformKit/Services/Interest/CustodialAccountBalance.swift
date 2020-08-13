//
//  CustodialAccountBalance.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct CustodialAccountBalance: Equatable {

    let available: MoneyValue
    
    init(currency: CurrencyType, response: CustodialBalanceResponse.Balance) {
        self.available = (try? MoneyValue(minor: response.available, currency: currency.code)) ?? .zero(currency)
    }
    
    public init(available: MoneyValue) {
        self.available = available
    }
}