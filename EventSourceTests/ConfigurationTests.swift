//
//  EventSourceTests.swift
//  EventSourceTests
//
//  Created by Andres on 2/13/15.
//  Copyright (c) 2015 Inaka. All rights reserved.
//

import UIKit
import XCTest
@testable import EventSource

class ConfigurationTests: XCTestCase {

	let domain = "http://testdomain.com"
	var sut: TestableEventSource!
	
	override func setUp() {
		sut = TestableEventSource(url: domain, headers: ["Authorization" : "basic auth"])
		super.setUp()
	}
	
	func testURL() {
		let sut = TestableEventSource(url: "http://test.com", headers: ["Authorization" : "basic auth"])
		XCTAssertEqual("http://test.com", sut.url.absoluteString, "the URL should be the same")
	}

	func testCreateEventSourceWithNoHeaders() {
		let sut = TestableEventSource(url: "http://test.com")
		XCTAssertEqual("http://test.com", sut.url.absoluteString, "the URL should be the same")
	}

	func testBasicAuth() {
		// basic auth token: "Basic base64(username + ':' + password)"
		// basic auth token: "Basic base64("testUsername" + ":" + "testPassword")"
		// basic auth token: "Basic dGVzdFVzZXJuYW1lOnRlc3RQYXNzd29yZA=="

		let basicAuthToken = "Basic dGVzdFVzZXJuYW1lOnRlc3RQYXNzd29yZA=="

		let username = "testUsername"
		let password = "testPassword"
		let basicAuthString = EventSource.basicAuth(username, password: password)

		XCTAssertEqual(basicAuthString, basicAuthToken)
	}

	func testEventsList(){
		let sut = TestableEventSource(url: "http://test.com")
		sut.addEventListener("first") { (id, event, data) in
			print("id")
		}

		sut.addEventListener("second") { (id, event, data) in
			print("id")
		}

		XCTAssertEqual(sut.events(), ["first","second"])
	}

	func testRemoveEventListeners(){
		let sut = TestableEventSource(url: "http://test.com")
		sut.addEventListener("first") { (id, event, data) in
			print("id")
		}

		sut.removeEventListener("first")
		XCTAssertEqual(sut.events().count, 0)
	}

	func testDefaultRetryTimeAndChangeRetryTime() {
		let expectation = self.expectationWithDescription("")

		XCTAssertEqual(3000, self.sut.retryTime, "the default retry time should be 3000")

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
			XCTAssertEqual(5000, self.sut.retryTime, "the retry time should be 5000 after changing it")
			expectation.fulfill()
		}

		sut.callDidReceiveData("retry: 5000\n\n".dataUsingEncoding(NSUTF8StringEncoding)!)
		self.waitForExpectationsWithTimeout(4) { (error) in
			if let _ = error{
				XCTFail("Expectation not fulfilled")
			}
		}

	}
}
