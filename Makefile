
xcodebuild?=/usr/bin/xcodebuild
xcrun?=/usr/bin/xcrun

KEYCHAIN_PROFILE:=notarization-profile
PRODUCT_NAME:=ImgurBar
TMP:=$(shell mktemp -dt com.ailinykh.${PRODUCT_NAME})

ARCHIVE_PATH?=$(TMP)/$(PRODUCT_NAME).xcarchive
DERIVED_DATA_PATH?=$(TMP)/DerivedData
RESULT_BUNDLE_PATH?=$(TMP)/$(PRODUCT_NAME).xcresult

EXPORT_PATH?=$(TMP)/$(PRODUCT_NAME).exported
APP_PATH?=$(EXPORT_PATH)/$(PRODUCT_NAME).app
ZIP_PATH?=$(TMP)/$(PRODUCT_NAME).zip
DMG_PATH?=$(TMP)/$(PRODUCT_NAME).dmg

.PHONY: archive
archive:
	$(xcodebuild) clean archive \
        -project $(PRODUCT_NAME).xcodeproj \
        -configuration Release \
        -scheme $(PRODUCT_NAME) \
        -sdk macosx -destination "platform=macOS" \
        -archivePath $(ARCHIVE_PATH) \
        -derivedDataPath $(DERIVED_DATA_PATH) \
        -resultBundlePath $(RESULT_BUNDLE_PATH) \
        ONLY_ACTIVE_ARCH=NO

ifdef TEAM_ID
$(shell plutil -replace teamID -string ${TEAM_ID} exportOptions.plist)
endif

.PHONY: export
export: archive
	$(xcodebuild) -exportArchive \
        -archivePath $(ARCHIVE_PATH) \
        -exportPath $(EXPORT_PATH) \
        -exportOptionsPlist exportOptions.plist

# xcrun notarytool store-credentials --key <KEY.p8> --key-id <KEY_ID> --issuer <KEY_ISSUER> $(KEYCHAIN_PROFILE)
# xcrun notarytool log <SUBMISSION_ID> --keychain-profile $(KEYCHAIN_PROFILE)
.PHONY: notarize
notarize: export
	/usr/bin/ditto -c -k --keepParent $(APP_PATH) $(ZIP_PATH); \
    $(xcrun) notarytool submit $(ZIP_PATH) --verbose --wait --keychain-profile $(KEYCHAIN_PROFILE); \
    $(xcrun) stapler staple $(APP_PATH)

.PHONY: validate
validate:
	spctl -av $(APP_PATH)

.PHONY: dmg
dmg: export
	hdiutil create -fs HFS+ -srcfolder $(APP_PATH) -volname $(PRODUCT_NAME) $(DMG_PATH)