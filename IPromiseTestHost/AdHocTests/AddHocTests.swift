//  MIT Licence
//  Copyright © 2016 Ivan Milinkovic

import Foundation

struct MyError : Error, CustomStringConvertible {
    
    let msg : String
    
    var description: String {
        return msg
    }
    
}


class AdHocTests {
    
    class func fetch() -> IFuture<String, NSError> {
        
        let promise = IPromise<String, NSError>()
        
        let dt = DispatchTime.now() + Double(3 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dt, execute: {
            promise.resolve("test")
//            promise.resolve(MyError(msg: "my error")) // or try an error
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
            print("observer 1: " + value)
        }.onError { (error) in
            print("observer 1: " + error.description)
        }
        
        let f2 = f.map { (value) -> String in
            return value + value
        }
        .onValue { (value) in
            print("observer 2: " + value)
            
            let dt = DispatchTime.now() + Double(1500 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dt, execute: {
                f.onValue({ (value) in
                    print("observer 3: \(value)")
                }).onError { (error) in
                    print("observer 3: " + error.description)
                }
            })
        }.onError { (error) in
            print("observer 2: " + error.description)
        }
        
        
        f2.map { (value) -> Int in
            return value.characters.count
        }
        .onValue { (value) in
            print("observer 4: " + value.description)
        }.onError { (error) in
            print("observer 4: " + error.description)
        }
    }
    
}






