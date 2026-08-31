.PHONY: test generate build-ios

test:
	swift test --package-path Packages/RippleDomain
	swift test --package-path Packages/RippleData
	swift test --package-path Packages/RippleIntentsCore
	swift test --package-path Packages/RippleUI

generate:
	xcodegen generate

build-ios:
	xcodebuild -workspace Ripple.xcworkspace -scheme RippleiOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO build
