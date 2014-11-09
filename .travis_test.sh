#!/bin/bash

xcodebuild -workspace AQSPocketActivity.xcworkspace -scheme AQSPocketActivity -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.1' test | xcpretty -c && exit ${PIPESTATUS[0]}

