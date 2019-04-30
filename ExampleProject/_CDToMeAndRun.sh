bundle install
bundle exec pod install
bundle exec fastlane beta
./Pods/SwiftInfo/swiftinfo
echo "-------"
echo "This bash script runs SwiftInfo outside of fastlane so you can see the output, but check out the Fastfile to see how you could use this in a real project."