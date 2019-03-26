import XCTest

extension FileUtilsTests {
    static let __allTests = [
        ("testBuildLogs", testBuildLogs),
        ("testInfofileFinder", testInfofileFinder),
        ("testLastOutput", testLastOutput),
        ("testSaveOutput", testSaveOutput),
        ("testTestLogs", testTestLogs),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FileUtilsTests.__allTests),
    ]
}
#endif
