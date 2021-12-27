//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import AuthenticationServices
import ImgurCore

@available(macOS 10.15, *)
final class ModernAuthClient: NSObject, AuthClient {
    func open(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "imgurbar") { url, error in
            guard let url = url else {
                completion(.failure(error ?? NSError(domain: "unknown", code: 0)))
                return
            }
            completion(.success(url))
        }
        session.presentationContextProvider = self
        session.start()
    }
}

@available(macOS 10.15, *)
extension ModernAuthClient: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return NSApp.windows.last ?? NSWindow()
    }
}
