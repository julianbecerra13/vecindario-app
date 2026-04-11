.PHONY: analyze test build-apk deploy-functions deploy-rules deploy-all

# Flutter
analyze:
	flutter analyze --no-fatal-infos

test:
	flutter test --coverage

build-apk:
	flutter build apk --release

build-ios:
	flutter build ios --release --no-codesign

# Firebase Deploy
deploy-functions:
	bash scripts/deploy_functions.sh

deploy-rules:
	bash scripts/deploy_firestore.sh

deploy-all: deploy-rules deploy-functions

# Code Generation
codegen:
	dart run build_runner build --delete-conflicting-outputs

codegen-watch:
	dart run build_runner watch --delete-conflicting-outputs

# Helpers
clean:
	flutter clean && flutter pub get

deps:
	flutter pub get
