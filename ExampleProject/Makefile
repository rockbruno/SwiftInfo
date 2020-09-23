.PHONY : swiftinfo

swiftinfo:
	cd ../ && make build
	cd ../ && make package
	rm -rf SwiftInfo-bin
	mkdir SwiftInfo-bin
	cp ../.build/release/_PRODUCT/swiftinfo.zip ./SwiftInfo-bin
	cd ./SwiftInfo-bin && unzip swiftinfo.zip 
	bundle install
	bundle exec fastlane beta
	./SwiftInfo-bin/bin/swiftinfo
	echo "-------"
	echo "This bash script runs SwiftInfo outside of fastlane so you can see the output, but check out the Fastfile to see how you could use this in a real project."