//  MIT Licence
//  Copyright © 2016 Ivan Milinkovic

import Foundation

private enum IFutureResult<T,E> {
    case value(T)
    case error(E)
}


open class IFuture <T, E> {
    
    fileprivate var result : IFutureResult<T, E>? = nil
    
    fileprivate typealias SuccessClosure = (_ value: T)->Void
    fileprivate typealias ErrorClosure = (_ error: E)->Void
    
    fileprivate var onValueClosures: [SuccessClosure] = []
    fileprivate var onErrorClosures: [ErrorClosure] = []
    
    // synchronization queue to serialize all execution to avoid race conditions
    fileprivate var syncQueue : DispatchQueue
    
    public convenience init() {
        self.init(synchronizationQueue: DispatchQueue.main)
    }
    
    /**
     @param synchronizationQueue A dispatch queue used to synchronize execution on crutucal sections
     */
    public init(synchronizationQueue: DispatchQueue) {
        self.syncQueue = synchronizationQueue
    }
    
    @discardableResult open func onValue(_ closure: @escaping (_ value: T)->Void) -> IFuture <T, E> {
        
        performOnSyncQueue {
            
            if let result = self.result {
                if case .value(let val) = result {
                    closure(val)
                }
            }
            else {
                self.onValueClosures.append(closure)
            }
        }
        
        return self
    }
    
    @discardableResult open func onError(_ closure: @escaping (_ error: E)->Void) -> IFuture <T, E> {
        
        performOnSyncQueue {
            
            if let result = self.result {
                if case .error(let err) = result {
                    closure(err)
                }
            }
            else {
                self.onErrorClosures.append(closure)
            }
        }
        
        return self
    }
    
    fileprivate func resolve(_ value: T) {
        performOnSyncQueue {
            self.result = .value(value)
            self.resolveCallbacks()
        }
    }
    
    fileprivate func resolve(_ error: E) {
        performOnSyncQueue {
            self.result = .error(error)
            self.resolveCallbacks()
        }
    }
    
    fileprivate func resolveCallbacks() {
        self.runStoredCallbacks()
        self.clearStoredCallbacks()
    }
    
    fileprivate func runStoredCallbacks() {
        
        assert(result != nil, "must be resolved")
        
        switch result! {
        case .value(let value):
            for c in onValueClosures {
                c(value)
            }
        case .error(let error):
            for c in onErrorClosures {
                c(error)
            }
        }
        
    }
    
    fileprivate func clearStoredCallbacks () {
        onValueClosures = []
        onErrorClosures = []
    }
    
    fileprivate func performOnSyncQueue(_ closure: @escaping ()->Void) {
        syncQueue.async(execute: closure)
    }
    
    
    open func map <T2> (_ transform: @escaping (_ value: T)-> T2 ) -> IFuture<T2,E> {
        
        let newFuture = IFuture<T2,E>()
        
        performOnSyncQueue {
            
            self.onValue { (value) in
                let newVal = transform(value)
                newFuture.resolve(newVal)
            }
            
            self.onError { (error) in
                newFuture.resolve(error)
            }
        }
        
        return newFuture
    }
    
}



open class IPromise<T,E> {
    
    open let future : IFuture<T,E>
    
    public init() {
        future = IFuture<T,E>()
    }
    
    open func resolve(_ value: T) {
        future.resolve(value)
    }
    
    open func resolve(_ error: E) {
        future.resolve(error)
    }
    
}





