import XCTest

/// Helper class providing access to the currently executing XCTestCase instance, if any
@objc public final class CurrentTestCaseTracker: NSObject, XCTestObservation {
    @objc static let sharedInstance = CurrentTestCaseTracker()

    private(set) var currentTestCase: XCTestCase?

    private var stashed_swift_reportFatalErrorsToDebugger: Bool = false

    @objc func testCaseWillStart(_ testCase: XCTestCase) {
        currentTestCase = testCase
    }

    @objc func testCaseDidFinish(_ testCase: XCTestCase) {
        currentTestCase = nil
    }
}

extension XCTestCase {
    var sanitizedName: String? {
        let fullName = self.name
        let characterSet = CharacterSet(charactersIn: "[]+-")
        #if swift(>=4)
            let name = fullName.components(separatedBy: characterSet).joined()
        #else
            let name = (fullName ?? "").components(separatedBy: characterSet).joined()
        #endif

        if let quickClass = NSClassFromString("QuickSpec"), self.isKind(of: quickClass) {
            let className = String(describing: type(of: self))
            if let range = name.range(of: className), range.lowerBound == name.startIndex {
                return name.replacingCharacters(in: range, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return name
    }
}
