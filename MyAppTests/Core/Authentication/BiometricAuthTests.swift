import Testing
@testable import MyApp

struct BiometricAuthTests {

    @Test("Mock returns configured biometric type")
    func biometricType() async {
        let auth = MockBiometricAuth(biometricType: .faceID)
        let type = await auth.biometricType
        #expect(type == .faceID)
    }

    @Test("Mock returns configured availability")
    func availability() async {
        let auth = MockBiometricAuth(isAvailable: true)
        let available = await auth.isAvailable
        #expect(available == true)
    }

    @Test("Successful authentication returns true")
    func successfulAuth() async throws {
        let auth = MockBiometricAuth(shouldSucceed: true)
        let result = try await auth.authenticate(reason: "Test")
        #expect(result == true)
    }

    @Test("Failed authentication returns false")
    func failedAuth() async throws {
        let auth = MockBiometricAuth(shouldSucceed: false)
        let result = try await auth.authenticate(reason: "Test")
        #expect(result == false)
    }

    @Test("Authentication throws configured error")
    func throwsError() async throws {
        let auth = MockBiometricAuth(errorToThrow: .userCanceled)

        do {
            _ = try await auth.authenticate(reason: "Test")
            #expect(Bool(false), "Should have thrown error")
        } catch let error as BiometricAuthError {
            #expect(error == .userCanceled)
        }
    }

    @Test("Configure updates mock state")
    func configure() async {
        let auth = MockBiometricAuth()
        await auth.configure(type: .touchID, available: false, succeeds: false)

        let type = await auth.biometricType
        let available = await auth.isAvailable

        #expect(type == .touchID)
        #expect(available == false)
    }
}
