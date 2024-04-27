# ImgurBar

[![macOS CI Status](https://github.com/ailinykh/ImgurBar/workflows/CI-macOS/badge.svg)](https://github.com/ailinykh/ImgurBar/actions?query=workflow%3ACI-macOS)

This is an macOS menubar application that makes it easy
to upload images to imgur.com.

![Upload via drag'n'drop](https://user-images.githubusercontent.com/939390/79070981-af5fd300-7ce1-11ea-8087-53bc75fba70a.gif)

Simply drag and drop image to the status bar icon.

Automatic screenshots uploading is also supported

# HowTo use

- clone repo
- obtain `CLIENT_ID` at [api.imgur.com](https://api.imgur.com/oauth2/addclient)
- insert in [Info.plist](https://github.com/ailinykh/ImgurBar/blob/master/ImgurBar/Info.plist#L40) file
- build an app

# Notarization
In case you are member of [Apple Developer Program](https://developer.apple.com/programs/) it's possible to [notarize](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution) app for distribution.

To perform notarization you should follow this steps:
- Create new [App Store Connect API Key](https://appstoreconnect.apple.com/access/integrations/api)
- Save credentials in the keychain: 
  - `xcrun notarytool store-credentials --key <KEY.p8> --key-id <KEY_ID> --issuer <KEY_ISSUER> notarization-profile`
- Place [Developer ID certificate](https://developer.apple.com/help/account/create-certificates/create-developer-id-certificates/) to you current Keychain
- Find __Team ID__ at [Membership Details](https://developer.apple.com/account) section
- Run notarization:
  - `make notarize validate TEAM_ID=<YOUR_TEAM_ID>`
- Wait for message:
  - _The staple and validate action worked!_
- You're amazing!

# Thanks

Thanks to [zbuc](https://github.com/zbuc/imgurBar) for idea

# License

imgurBar is licensed under the BSD license.

