import Testing
@testable import MyApp

@Suite("HTTPMethod Tests")
struct HTTPMethodTests {

    @Test("HTTPMethod has correct raw values")
    func testRawValues() {
        #expect(HTTPMethod.get.rawValue == "GET")
        #expect(HTTPMethod.post.rawValue == "POST")
        #expect(HTTPMethod.put.rawValue == "PUT")
        #expect(HTTPMethod.delete.rawValue == "DELETE")
    }
}
