//  MIT Licence
//  Copyright © 2016 Ivan Milinkovic

import Foundation

struct MyError : ErrorType, CustomStringConvertible {
    
    let msg : String
    
    var description: String {
        return msg
    }
    
}


class AdHocTests {
    
    class func fetch() -> IFuture<String, NSError> {
        
        let promise = IPromise<String, NSError>()
        
        let dt = dispatch_time(DISPATCH_TIME_NOW, 3 * Int64(NSEC_PER_SEC))
        dispatch_after(dt, dispatch_get_main_queue(), {
            promise.resolve("test")
//            promise.resolve(MyError(msg: "my error"))
        })
        
        return promise.future
    }
    
    class func testPromise()
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
    
    
    
    class func test() {
        
        let f = fetch()
        
        f.onValue { (value) in
            print("obs 1: " + value)
        }.onError { (error) in
            print("obs 1: " + error.description)
        }
        
        let f2 = f.map { (value) -> String in
            return value + value
        }
        .onValue { (value) in
            print("obs 2: " + value)
            
            let dt = dispatch_time(DISPATCH_TIME_NOW, 1500 * Int64(NSEC_PER_MSEC))
            dispatch_after(dt, dispatch_get_main_queue(), {
                f.onValue({ (value) in
                    print("obs 3: \(value)")
                }).onError { (error) in
                    print("obs 3: " + error.description)
                }
            })
        }.onError { (error) in
            print("obs 2: " + error.description)
        }
        
        
        f2.map { (value) -> Int in
            return value.characters.count
        }
        .onValue { (value) in
            print("obs 4: " + value.description)
        }.onError { (error) in
            print("obs 4: " + error.description)
        }
    }
    
}






