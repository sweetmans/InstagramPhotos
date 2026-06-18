import Foundation

final class ContinuationGuard: @unchecked Sendable {
    private let lock = NSLock()
    private var isResumed = false

    func resumeOnce<T, E: Error>(
        _ continuation: CheckedContinuation<T, E>,
        returning value: T
    ) {
        lock.lock()
        defer { lock.unlock() }
        guard !isResumed else { return }
        isResumed = true
        continuation.resume(returning: value)
    }

    func resumeOnce<T, E: Error>(
        _ continuation: CheckedContinuation<T, E>,
        throwing error: E
    ) {
        lock.lock()
        defer { lock.unlock() }
        guard !isResumed else { return }
        isResumed = true
        continuation.resume(throwing: error)
    }
}