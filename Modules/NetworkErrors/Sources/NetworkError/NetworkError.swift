// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A networking error returned by the network layer, this can be mapped to user facing errors at a high level
public enum NetworkError: Error {
    case urlError(URLError)
    case serverError(HTTPRequestServerError)
    case rawServerError(ServerErrorResponse)
    case payloadError(HTTPRequestPayloadError)
    case authentication(Error)
}

extension NetworkError: FromNetworkError {

    public static func from(_ networkError: NetworkError) -> NetworkError {
        networkError
    }
}

/// A simple implementation of `Equatable` for now. I might make sense to improve this, eventually.
extension NetworkError: Equatable {

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}