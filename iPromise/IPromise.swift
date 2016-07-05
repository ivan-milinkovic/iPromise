//  MIT Licence
//  Copyright © 2016 Ivan Milinkovic

import Foundation

private enum IFutureResult<T,E> {
    case Value(T)
    case Error(E)
}


class IFuture <T, E> {
    
    private var result : IFutureResult<T, E>? = nil
    
    typealias SuccessClosure = (value: T)->Void
    typealias ErrorClosure = (error: E)->Void
    
    private var onValueClosures: [SuccessClosure] = []
    private var onErrorClosures: [ErrorClosure] = []
    
    // synchronization queue to serialize all execution to avoid race conditions
    private var syncQueue : dispatch_queue_t = dispatch_get_main_queue()
    
    
    func onValue(closure: (value: T)->Void) -> IFuture <T, E> {
        
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
    
    func onError(closure: (error: E)->Void) -> IFuture <T, E> {
        
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
            self.runStoredCallbacks()
            self.clearStoredCallbacks()
        }
    }
    
    private func resolve(error: E) {
        performOnSyncQueue {
            self.result = .Error(error)
            self.runStoredCallbacks()
            self.clearStoredCallbacks()
        }
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
    
    
    func map <T2> (transform: (value: T)-> T2 ) -> IFuture<T2,E> {
        
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



class IPromise<T,E> {
    
    let future : IFuture<T,E>
    
    init() {
        future = IFuture<T,E>()
    }
    
    func resolve(value: T) {
        future.resolve(value)
    }
    
    func resolve(error: E) {
        future.resolve(error)
    }
    
}





