// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

/// Fetches the supported pairs
protocol SupportedPairsClientAPI: AnyObject {
    /// Fetch the supported pairs according to a given fetch-option
    func supportedPairs(
        with option: SupportedPairsFilterOption
    ) -> AnyPublisher<SupportedPairsResponse, NabuNetworkError>
}
