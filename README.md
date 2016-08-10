# iPromise

iPromise is a simple Promise/Future pattern implementation, created to be simple, 
lightweight, with no dependencies, and easy to integrate (just copy one file to you project). It uses no locks, but utilizes GCD for synchronization.

An example:

```swift
    // using iPromise API 
    func testPromise()
    {
        let future = asyncFetchValue()
        
        future
        .onValue { (value) in
            print("got a value: \(value)")
        }
        .onError { (error) in
            print("got an error: \(error)")
        }
    }
    
    // adapt a completion block based API to a future based
    func asyncFetchValue() -> IFuture<String, NSError> {
        
        let promise = IPromise<String, NSError>()
        
        performAsyncTask(completion: { value in
            promise.resolve(value)
        })
        
        return promise.future
    }

```

## Installation

Just copy the IPromise.swift file to your project.

:) 

## TODO:

Finish unit tests.

---
