import Foundation

public protocol NativeVisibilityAssertion: AnyObject {
    func invalidate()
}

@MainActor
public protocol NativeVisibilityProviding: AnyObject {
    var isAvailable: Bool { get }
    func activate(allowedSystemItems: [Int],
                  allowedBundleIdentifiers: [String],
                  completion: @escaping @MainActor (Result<NativeVisibilityAssertion, Error>) -> Void)
}

@MainActor
public final class NativeVisibilityBridge: NativeVisibilityProviding {
    public static let shared = NativeVisibilityBridge()

    private let frameworkHandle: UnsafeMutableRawPointer?
    private let cfgClass: AnyClass?
    private let asrtClass: AnyClass?

    private let initSel = NSSelectorFromString("initWithAllowedSystemItems:allowedBundleIdentifiers:")
    private let actSel = NSSelectorFromString("activateWithConfiguration:completionHandler:")
    private let invSel = NSSelectorFromString("invalidate")

    private typealias InitFunc = @convention(c) (AnyObject, Selector, NSArray, NSArray) -> AnyObject
    private typealias ActFunc = @convention(c) (AnyObject, Selector, AnyObject, @convention(block) @escaping (NSError?) -> Void) -> Void
    private typealias InvFunc = @convention(c) (AnyObject, Selector) -> Void

    public var isAvailable: Bool {
        return frameworkHandle != nil && cfgClass != nil && asrtClass != nil
    }

    private init() {
        let path = "/System/Library/PrivateFrameworks/MenuBarClientCore.framework/MenuBarClientCore"
        self.frameworkHandle = dlopen(path, RTLD_NOW | RTLD_LOCAL)
        self.cfgClass = NSClassFromString("MBAssessmentModeConfiguration")
        self.asrtClass = NSClassFromString("MBAssessmentModeAssertion")

        if isAvailable {
            NSLog("NativeVisibilityBridge: MenuBarClientCore successfully loaded for macOS 27+")
        } else {
            NSLog("NativeVisibilityBridge: MenuBarClientCore unavailable (using legacy mode)")
        }
    }

    public func activate(allowedSystemItems: [Int],
                         allowedBundleIdentifiers: [String],
                         completion: @escaping @MainActor (Result<NativeVisibilityAssertion, Error>) -> Void) {
        guard isAvailable, let cfgClass = cfgClass, let asrtClass = asrtClass else {
            completion(.failure(NSError(domain: "NativeVisibilityBridge", code: 1, userInfo: [NSLocalizedDescriptionKey: "MenuBarClientCore is not available on this macOS"])))
            return
        }

        let systemItemsArray = allowedSystemItems.map { NSNumber(value: $0) } as NSArray
        let bundlesArray = allowedBundleIdentifiers as NSArray

        guard let cfgAlloc = (cfgClass as? NSObject.Type)?.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() else {
            completion(.failure(NSError(domain: "NativeVisibilityBridge", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to allocate configuration"])))
            return
        }

        let initMethod = unsafeBitCast(cfgAlloc.method(for: initSel), to: InitFunc.self)
        let config = initMethod(cfgAlloc, initSel, systemItemsArray, bundlesArray)

        guard let asrtAlloc = (asrtClass as? NSObject.Type)?.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue(),
              let asrtInit = asrtAlloc.perform(NSSelectorFromString("init"))?.takeUnretainedValue() else {
            completion(.failure(NSError(domain: "NativeVisibilityBridge", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize assertion"])))
            return
        }

        let actMethod = unsafeBitCast(asrtInit.method(for: actSel), to: ActFunc.self)
        let invMethod = unsafeBitCast(asrtInit.method(for: invSel), to: InvFunc.self)
        let invSelector = self.invSel

        actMethod(asrtInit, actSel, config) { error in
            Task { @MainActor in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let handle = AssertionHandle(assertionObject: asrtInit, invalidateMethod: invMethod, invalidateSelector: invSelector)
                    completion(.success(handle))
                }
            }
        }
    }

    private final class AssertionHandle: NativeVisibilityAssertion {
        private var assertionObject: AnyObject?
        private let invalidateMethod: InvFunc
        private let invalidateSelector: Selector

        init(assertionObject: AnyObject, invalidateMethod: @escaping InvFunc, invalidateSelector: Selector) {
            self.assertionObject = assertionObject
            self.invalidateMethod = invalidateMethod
            self.invalidateSelector = invalidateSelector
        }

        func invalidate() {
            guard let obj = assertionObject else { return }
            self.assertionObject = nil
            invalidateMethod(obj, invalidateSelector)
        }

        deinit {
            invalidate()
        }
    }
}
