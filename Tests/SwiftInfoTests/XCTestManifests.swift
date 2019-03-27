import XCTest

extension CoreTests {
    static let __allTests = [
        ("testFullRun", testFullRun),
        ("testFullRunWithEmptyOutput", testFullRunWithEmptyOutput),
    ]
}

extension FileUtilsTests {
    static let __allTests = [
        ("testBuildLogs", testBuildLogs),
        ("testInfofileFinder", testInfofileFinder),
        ("testLastOutput", testLastOutput),
        ("testSaveOutput", testSaveOutput),
        ("testTestLogs", testTestLogs),
    ]
}

extension ProviderTests {
    static let __allTests = [
        ("testIPASize", testIPASize),
        ("testTargetCount", testTargetCount),
        ("testTestCount", testTestCount),
        ("testWarningCount", testWarningCount),
    ]
}

extension SlackFormatterTests {
    static let __allTests = [
        ("testFormatter", testFormatter),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CoreTests.__allTests),
        testCase(FileUtilsTests.__allTests),
        testCase(ProviderTests.__allTests),
        testCase(SlackFormatterTests.__allTests),
    ]
}
#endif
