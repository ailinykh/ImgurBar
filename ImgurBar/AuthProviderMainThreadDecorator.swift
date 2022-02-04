//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

import Foundation
import ImgurCore

final class AuthProviderMainThreadDecorator: AuthProvider {
    let decoratee: AuthProvider
    
    init(decoratee: AuthProvider) {
        self.decoratee = decoratee
    }
    
    func authorize(completion: @escaping (Result<Account, Error>) -> Void) {
        decoratee.authorize { result in
            guard Thread.isMainThread else {
                DispatchQueue.main.async {
                    completion(result)
                }
                return
            }
            completion(result)
        }
    }
}
