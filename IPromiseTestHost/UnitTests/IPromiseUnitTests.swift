//  MIT Licence
//  Copyright © 2016 Ivan Milinkovic

import XCTest


class IPromiseTestHostTests: XCTestCase {
    
    typealias TestValueType = String
    typealias TestErrorType = NSError
    
    var receivedValue : TestValueType? = nil
    var receivedError : TestErrorType? = nil
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.receivedValue = nil
        self.receivedError = nil
    }
    
    func createNsError() -> NSError {
        return NSError(domain: "iPromiseUnitTests", code: 1, userInfo: nil)
    }
    
    func testWaitForValue () {
        
        let promise = IPromise<TestValueType, TestErrorType>()
        let future = promise.future
        let expected = "test123"
        
        // asynchronously resolve the promise
        dispatch_async(dispatch_get_main_queue()) {
            promise.resolve(expected)
        }
        
        // wait for value/error
        let exp = self.expectationWithDescription("")
        future.onValue { (value) in
            self.receivedValue = value
            exp.fulfill()
        }
        future.onError { (error) in
            self.receivedError = error
            exp.fulfill()
        }
        
        // assert nothing is received before the promise is resolved
        XCTAssertNil(self.receivedValue)
        XCTAssertNil(self.receivedError)
        
        // assert the final outcome
        waitForExpectationsWithTimeout(1) { (error : NSError?) in
            
            XCTAssertNil(error, "error: \(error)")
            XCTAssertNotNil(self.receivedValue)
            XCTAssertNil(self.receivedError)
            XCTAssert(self.receivedValue == expected)
        }
        
    }
    
    
    
    func testWaitForError () {
        let promise = IPromise<TestValueType, TestErrorType>()
        let future = promise.future
        let expected = self.createNsError()
        
        // asynchronously resolve the promise
        dispatch_async(dispatch_get_main_queue()) {
            promise.resolve(expected)
        }
        
        // wait for value/error
        let exp = self.expectationWithDescription("")
        future.onValue { (value) in
            self.receivedValue = value
            exp.fulfill()
        }
        future.onError { (error) in
            self.receivedError = error
            exp.fulfill()
        }
        
        // assert nothing is received before the promise is resolved
        XCTAssertNil(self.receivedValue)
        XCTAssertNil(self.receivedError)
        
        // assert the final outcome
        waitForExpectationsWithTimeout(1) { (error : NSError?) in
            
            XCTAssertNil(error, "error: \(error)")
            XCTAssertNil(self.receivedValue)
            XCTAssertNotNil(self.receivedError)
            XCTAssert(self.receivedError == expected)
        }
        
    }
    
    
    
    
    func testValueIsAlreadyThere () {
        
        let promise = IPromise<TestValueType, TestErrorType>()
        let future = promise.future
        let expected = "test123"
        
        // asynchronously resolve the promise
        let exp = self.expectationWithDescription("")
        dispatch_async(dispatch_get_main_queue()) {
            
            promise.resolve(expected)
            
            future.onValue { (value) in
                self.receivedValue = value
                exp.fulfill()
            }
            future.onError { (error) in
                self.receivedError = error
                exp.fulfill()
            }
            
            
        }
        
        // assert nothing is received before the promise is resolved
        XCTAssertNil(self.receivedValue)
        XCTAssertNil(self.receivedError)
        
        waitForExpectationsWithTimeout(1) { (error : NSError?) in
            
            XCTAssertNil(error, "error: \(error)")
            
            XCTAssertNotNil(self.receivedValue)
            XCTAssertNil(self.receivedError)
            XCTAssert(self.receivedValue == expected)
        }
        
    }
    
    
    
    
    
    func testErrorIsAlreadyThere () {
        
        let promise = IPromise<TestValueType, TestErrorType>()
        let future = promise.future
        let expected = self.createNsError()
        
        // asynchronously resolve the promise
        let exp = self.expectationWithDescription("")
        dispatch_async(dispatch_get_main_queue()) {
            
            promise.resolve(expected)
            
            future.onValue { (value) in
                self.receivedValue = value
                exp.fulfill()
            }
            future.onError { (error) in
                self.receivedError = error
                exp.fulfill()
            }
            
            
        }
        
        // assert nothing is received before the promise is resolved
        XCTAssertNil(self.receivedValue)
        XCTAssertNil(self.receivedError)
        
        waitForExpectationsWithTimeout(1) { (error : NSError?) in
            
            XCTAssertNil(error, "error: \(error)")
            
            XCTAssertNil(self.receivedValue)
            XCTAssertNotNil(self.receivedError)
            XCTAssert(self.receivedError == expected)
        }
        
    }
    
    
    
    
    func testSynchronousResolve() {
        
        let promise = IPromise<TestValueType, TestErrorType>()
        let future = promise.future
        let expected = "test123"
        
        // synchronously resolve the promise
        promise.resolve(expected)
        
        // assert nothing is received before the promise is resolved
        XCTAssertNil(self.receivedValue)
        XCTAssertNil(self.receivedError)
        
        // wait for value/error
        let exp = self.expectationWithDescription("")
        future.onValue { (value) in
            self.receivedValue = value
            exp.fulfill()
        }
        future.onError { (error) in
            self.receivedError = error
            exp.fulfill()
        }
        
        // assert the final outcome
        waitForExpectationsWithTimeout(1) { (error : NSError?) in
            
            XCTAssertNil(error, "error: \(error)")
            XCTAssertNotNil(self.receivedValue)
            XCTAssertNil(self.receivedError)
            XCTAssert(self.receivedValue == expected)
        }
        
    }
    
    
    
    
    
    
    func testChainedValueSubscriptions() {
        
        let promise = IPromise<TestValueType, TestErrorType>()
        let future = promise.future
        let expected = "test123"
        
        // asynchronously resolve the promise
        dispatch_async(dispatch_get_main_queue()) {
            promise.resolve(expected)
        }
        
        var reportedVal1 : TestValueType? = nil
        var reportedVal2 : TestValueType? = nil
        var reportedErr1 : TestErrorType? = nil
        var reportedErr2 : TestErrorType? = nil
        
        // wait for value/error
        let exp = self.expectationWithDescription("")
        future.onValue { (value) in
            reportedVal1 = value
        }
        .onValue { (value) in
            reportedVal2 = value
            exp.fulfill()
        }
        
        future.onError { (error) in
            reportedErr1 = error
        }
        .onError { (error) in
            reportedErr2 = error
            exp.fulfill()
        }
        
        // assert nothing is received before the promise is resolved
        XCTAssertNil(reportedVal1)
        XCTAssertNil(reportedVal2)
        XCTAssertNil(reportedErr1)
        XCTAssertNil(reportedErr2)
        
        // assert the final outcome
        waitForExpectationsWithTimeout(1) { (error : NSError?) in
            
            XCTAssertNil(error, "error: \(error)")
            
            XCTAssertNotNil(reportedVal1)
            XCTAssertNotNil(reportedVal2)
            XCTAssertNil(reportedErr1)
            XCTAssertNil(reportedErr2)
            
            XCTAssert(reportedVal1 == expected)
            XCTAssert(reportedVal2 == expected)
        }
    }
    
    
    
    func testChainedErrorSubscriptions() {
        
        let promise = IPromise<TestValueType, TestErrorType>()
        let future = promise.future
        let expected = self.createNsError()
        
        // asynchronously resolve the promise
        dispatch_async(dispatch_get_main_queue()) {
            promise.resolve(expected)
        }
        
        var reportedVal1 : TestValueType? = nil
        var reportedVal2 : TestValueType? = nil
        var reportedErr1 : TestErrorType? = nil
        var reportedErr2 : TestErrorType? = nil
        
        // wait for value/error
        let exp = self.expectationWithDescription("")
        future.onValue { (value) in
            reportedVal1 = value
            }
            .onValue { (value) in
                reportedVal2 = value
                exp.fulfill()
        }
        
        future.onError { (error) in
            reportedErr1 = error
            }
            .onError { (error) in
                reportedErr2 = error
                exp.fulfill()
        }
        
        // assert nothing is received before the promise is resolved
        XCTAssertNil(reportedVal1)
        XCTAssertNil(reportedVal2)
        XCTAssertNil(reportedErr1)
        XCTAssertNil(reportedErr2)
        
        // assert the final outcome
        waitForExpectationsWithTimeout(1) { (error : NSError?) in
            
            XCTAssertNil(error, "error: \(error)")
            
            XCTAssertNil(reportedVal1)
            XCTAssertNil(reportedVal2)
            XCTAssertNotNil(reportedErr1)
            XCTAssertNotNil(reportedErr2)
            
            XCTAssert(reportedErr1 == expected)
            XCTAssert(reportedErr2 == expected)
        }
    }
    
    
    
    func testMapWithValue() {
        
        let promise = IPromise<TestValueType, TestErrorType>()
        let future = promise.future
        let expected = 123
        
        // asynchronously resolve the promise
        dispatch_async(dispatch_get_main_queue()) {
            promise.resolve("test123")
        }
        
        var reportedVal : Int = 0
        
        // wait for value/error
        let exp = self.expectationWithDescription("")
        future.onValue { (value) in
            self.receivedValue = value
            future.map({ (value) -> Int in
                return expected
            })
            .onValue({ (value) in
                reportedVal = value
                exp.fulfill()
            })
        }
        future.onError { (error) in
            self.receivedError = error
            exp.fulfill()
        }
        
        // assert nothing is received before the promise is resolved
        XCTAssertNil(self.receivedValue)
        XCTAssertNil(self.receivedError)
        
        // assert the final outcome
        waitForExpectationsWithTimeout(1) { (error : NSError?) in
            
            XCTAssertNil(error, "error: \(error)")
            XCTAssertNotNil(reportedVal)
            XCTAssertNil(self.receivedError)
            XCTAssert(reportedVal == expected)
        }

        
    }
    
    
    
    func testMapWithError() {
        
        let promise = IPromise<TestValueType, TestErrorType>()
        let future = promise.future
        let expected = self.createNsError()
        
        // asynchronously resolve the promise
        dispatch_async(dispatch_get_main_queue()) {
            promise.resolve(expected)
        }
        
        var reportedVal : Int? = nil
        
        // wait for value/error
        let exp = self.expectationWithDescription("")
        future.onValue { (value) in
            self.receivedValue = value
            exp.fulfill()
        }
        
        let mapFuture = future.onError { (error) in
            self.receivedError = error
        }.map { (value) -> Int in
            return 123
        }
        
        mapFuture.onValue { (value) in
            reportedVal = value
            exp.fulfill()
        }
        mapFuture.onError { (error) in
            self.receivedError = error
            exp.fulfill()
        }
        
        // assert nothing is received before the promise is resolved
        XCTAssertNil(self.receivedValue)
        XCTAssertNil(reportedVal)
        XCTAssertNil(self.receivedError)
        
        // assert the final outcome
        waitForExpectationsWithTimeout(10) { (error : NSError?) in
            
            XCTAssertNil(error, "error: \(error)")
            XCTAssertNil(reportedVal)
            XCTAssertNotNil(self.receivedError)
            XCTAssert(self.receivedError == expected)
        }
        
        
    }
    
    
}

