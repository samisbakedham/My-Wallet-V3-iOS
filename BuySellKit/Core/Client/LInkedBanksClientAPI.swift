//
//  LInkedBanksClientAPI.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol LinkedBanksClientAPI: AnyObject {
    /// Fetches any linked banks associated with the current user
    func linkedBanks() -> Single<[LinkedBankResponse]>

    /// Fetches a specific linked bank for the provided `id`
    /// - Parameter id: A `String` representing the id of the linked bank
    func getLinkedBank(for id: String) -> Single<LinkedBankResponse>

    /// Starts the proccess of creating a bank linkage
    /// - Parameter currency: A `FiatCurrency` value of the linked bank
    func createBankLinkage(for currency: FiatCurrency) -> Single<CreateBankLinkageResponse>

    /// Fetches a specific bank with
    /// - Parameter id: A `String` representing the id of the linked bank
    /// - Parameter providerAcountId: A `String` representing the `providerAcountId` from partner's response
    func updateBankLinkage(for id: String, providerAcountId: String) -> Single<LinkedBankResponse>
}
