//  MIT Licence
//  Copyright © 2016 Ivan Milinkovic

import Foundation

private enum IFutureResult<T,E> {
    case Value(T)
    case Error(E)
}


public class IFuture <T, E> {
    
    private var result : IFutureResult<T, E>? = nil
    
    private typealias SuccessClosure = (value: T)->Void
    private typealias ErrorClosure = (error: E)->Void
    
    private var onValueClosures: [SuccessClosure] = []
    private var onErrorClosures: [ErrorClosure] = []
    
    // synchronization queue to serialize all execution to avoid race conditions
    private var syncQueue : dispatch_queue_t
    
    public convenience init() {
        self.init(synchronizationQueue: dispatch_get_main_queue())
    }
    
    /**
     @param synchronizationQueue A dispatch queue used to synchronize execution on crutucal sections
     */
    public init(synchronizationQueue: dispatch_queue_t) {
        self.syncQueue = synchronizationQueue
    }
    
    public func onValue(closure: (value: T)->Void) -> IFuture <T, E> {
        
        performOnSyncQueue {
            
            if let result = self.result {
                if case .Value(let val) = result {
                    closure(value: val)
                }
            }
            else {
                self.onValueClosures.append(closure)
            }
        }
        
        return self
    }
    
    public func onError(closure: (error: E)->Void) -> IFuture <T, E> {
        
        performOnSyncQueue {
            
            if let result = self.result {
                if case .Error(let err) = result {
                    closure(error: err)
                }
            }
            else {
                self.onErrorClosures.append(closure)
            }
        }
        
        return self
    }
    
    private func resolve(value: T) {
        performOnSyncQueue {
            self.result = .Value(value)
            self.resolveCallbacks()
        }
    }
    
    private func resolve(error: E) {
        performOnSyncQueue {
            self.result = .Error(error)
            self.resolveCallbacks()
        }
    }
    
    private func resolveCallbacks() {
        self.runStoredCallbacks()
        self.clearStoredCallbacks()
    }
    
    private func runStoredCallbacks() {
        
        assert(result != nil, "must be resolved")
        
        switch result! {
        case .Value(let value):
            for c in onValueClosures {
                c(value: value)
            }
        case .Error(let error):
            for c in onErrorClosures {
                c(error: error)
            }
        }
        
    }
    
    private func clearStoredCallbacks () {
        onValueClosures = []
        onErrorClosures = []
    }
    
    private func performOnSyncQueue(closure: ()->Void) {
        dispatch_async(syncQueue, closure)
    }
    
    
    public func map <T2> (transform: (value: T)-> T2 ) -> IFuture<T2,E> {
        
        let newFuture = IFuture<T2,E>()
        
        performOnSyncQueue {
            
            self.onValue { (value) in
                let newVal = transform(value: value)
                newFuture.resolve(newVal)
            }
            
            self.onError { (error) in
                newFuture.resolve(error)
            }
        }
        
        return newFuture
    }
    
}



public class IPromise<T,E> {
    
    public let future : IFuture<T,E>
    
    public init() {
        future = IFuture<T,E>()
    }
    
    public func resolve(value: T) {
        future.resolve(value)
    }
    
    public func resolve(error: E) {
        future.resolve(error)
    }
    
}





