//
//  PersonalDetailsService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import RxSwift

class PersonalDetailsService: NSObject, PersonalDetailsAPI {

    private var disposable: Disposable?

    deinit {
        disposable?.dispose()
    }

    func update(personalDetails: KYCUpdatePersonalDetailsRequest, with completion: @escaping PersonalDetailsUpdateCompletion) {
        disposable = NabuAuthenticationService.shared.tokenString.flatMapCompletable { token in
            let headers = [HttpHeaderField.authorization: token]
            return KYCNetworkRequest.request(
                put: .updateUserDetails,
                parameters: personalDetails,
                headers: headers
            )
        }.subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: {
                completion(nil)
            }, onError: { error in
                completion(error)
            })
    }
}
