# iPromise

iPromise is a simple Promise/Future pattern implementation, created to be simple, 
lightweight, with no dependencies, and easy to integrate (just copy one file to you project). It uses no locks, but utilizes GCD for synchronization.

An example:

```swift
    func fetch() -> IFuture<String, NSError> {
        
        let promise = IPromise<String, NSError>()
        
        let dt = dispatch_time(DISPATCH_TIME_NOW, 3 * Int64(NSEC_PER_SEC))
        dispatch_after(dt, dispatch_get_main_queue(), {
            promise.resolve("test")
        })
        
        return promise.future
    }
    
    func testPromise()
    {
        let future = fetch()
        
        future
        .onValue { (value) in
            print("got a value: \(value)")
        }
        .onError { (error) in
            print("got an error: \(error)")
        }
    }

```

## Installation

Just copy the IPromise.swift file to your project.

:) 

## TODO:

Finish unit tests.

---