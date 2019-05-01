prepare:
	swift build -c release --disable-sandbox
	./prepare_for_release.sh

package:
	tar -zcvf "swiftinfo-2.2.0.tar.gz" ./bin