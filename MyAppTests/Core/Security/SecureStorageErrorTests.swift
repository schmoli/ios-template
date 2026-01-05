import Testing
import Foundation
@testable import MyApp

struct SecureStorageErrorTests {

    @Test("SecureStorageError.encodingFailed creates correct error")
    func encodingFailedError() {
        let error = SecureStorageError.encodingFailed("test message")
        #expect(error.localizedDescription == "Failed to encode value: test message")
    }

    @Test("SecureStorageError.decodingFailed creates correct error")
    func decodingFailedError() {
        let error = SecureStorageError.decodingFailed("test message")
        #expect(error.localizedDescription == "Failed to decode value: test message")
    }

    @Test("SecureStorageError.saveFailed creates correct error")
    func saveFailedError() {
        let error = SecureStorageError.saveFailed(-25300)
        #expect(error.localizedDescription == "Failed to save to keychain (status: -25300)")
    }

    @Test("SecureStorageError.loadFailed creates correct error")
    func loadFailedError() {
        let error = SecureStorageError.loadFailed(-25300)
        #expect(error.localizedDescription == "Failed to load from keychain (status: -25300)")
    }

    @Test("SecureStorageError.deleteFailed creates correct error")
    func deleteFailedError() {
        let error = SecureStorageError.deleteFailed(-25300)
        #expect(error.localizedDescription == "Failed to delete from keychain (status: -25300)")
    }

    @Test("SecureStorageError.notFound creates correct error")
    func notFoundError() {
        let error = SecureStorageError.notFound
        #expect(error.localizedDescription == "Item not found in keychain")
    }

    @Test("SecureStorageError equality works correctly")
    func equalityTest() {
        #expect(SecureStorageError.encodingFailed("a") == SecureStorageError.encodingFailed("a"))
        #expect(SecureStorageError.encodingFailed("a") != SecureStorageError.encodingFailed("b"))
        #expect(SecureStorageError.saveFailed(1) == SecureStorageError.saveFailed(1))
        #expect(SecureStorageError.saveFailed(1) != SecureStorageError.saveFailed(2))
        #expect(SecureStorageError.notFound == SecureStorageError.notFound)
        #expect(SecureStorageError.notFound != SecureStorageError.encodingFailed("test"))
    }
}
