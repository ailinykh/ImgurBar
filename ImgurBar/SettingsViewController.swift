//
//  SettingsViewController.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 12.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Cocoa
import AuthenticationServices

class SettingsViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func authorize(_ sender: AnyObject) {
        print(#function, sender)
        let url = URL(string:"https://api.imgur.com/oauth2/authorize?client_id=6069eccec0e8b51&response_type=token")!
#if !AUTHORIZATION_THROUGH_WEB_AUTHENTICATION_SESSION_ENABLED
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "com.ailinykh.ImgurBar") { url, error in
            guard let url = url else {
                print(error?.localizedDescription ?? "unknown error")
                return
            }
            
            print("url:", url)
        }
        
        session.presentationContextProvider = self
        print("sesion started:", session.start())
#else
        NSWorkspace.shared.open(url)
#endif
    }
}

extension SettingsViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}
