// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import BitcoinKit
import PlatformKit
import XCTest

final class UnspentOutputEffectiveValueTests: XCTestCase {

    private var p2pkhCoin: UnspentOutput {
        UnspentOutput.createP2PKH(with: .init(minor: 15000))
    }

    private var p2wpkhCoin: UnspentOutput {
        UnspentOutput.createP2WPKH(with: .init(minor: 15000))
    }

    func testCorrectP2PKHCoinValue() {
        XCTAssertEqual(
            p2pkhCoin.effectiveValue(fee: 55),
            6860
        ) // 15000 - 55 * 148 = 6860
    }

    func testCorrectP2WPKHCoinValue() {
        XCTAssertEqual(
            p2wpkhCoin.effectiveValue(fee: 55),
            11274
        ) // 15000 - 55 * 67.75 = 11273.75
    }

    func testShouldReturnZeroCoinValue() {
        XCTAssertEqual(
            p2pkhCoin.effectiveValue(fee: 55000),
            0
        )
    }

    func testShouldReturnMaxCoinValue() {
        XCTAssertEqual(
            p2pkhCoin.effectiveValue(fee: 0),
            15000
        )
    }
}
