//
//  SBTestTaskTests.swift
//  SBTestTaskTests
//
//  Created by Alex2 on 3/29/19.
//  Copyright © 2019 Alex Shekunsky. All rights reserved.
//

import XCTest
@testable import SBTestTask

class SBTestTaskTests: XCTestCase {
    
    var sut = GifSearchController()
    
    func testAPIWorking() {
        let expectation = self.expectation(description: "APIWorking")
        SwiftyGiphyAPI.shared.getSearch(searchTerm: "cat",
                                        limit: FetchGifsConstants.pageSize,
                                        rating: .pg13,
                                        offset: 0) {(error, response) in
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: TestsConstants.timeLimitForResponse)
    }
    
    func testResponsePagination() {
        SwiftyGiphyAPI.shared.getSearch(searchTerm: "cat",
                                        limit:TestsConstants.pageLimit,
                                        rating: .pg13,
                                        offset: 0) {(error, response) in
            XCTAssertEqual(TestsConstants.pageLimit, response?.gifs.count)
        }
    }
    
    func testAPIForEmptyResponse() {
        SwiftyGiphyAPI.shared.getSearch(searchTerm: TestsConstants.requestForEmptyResponse,
                                        limit: TestsConstants.pageLimit,
                                        rating: .pg13,
                                        offset: 0) {(error, response) in
            XCTAssertEqual(0, response?.gifs.count)
            XCTAssertEqual(nil, error)
        }
    }
    
    func testEmptyResponseResult() {
        let sut = self.sut
        let expectation = self.expectation(description: "APIEmptyResponseResult")
        sut.bindViewModel()
        sut.viewModel.searchText = TestsConstants.requestForEmptyResponse
        sut.errorLabel.isHidden = true
        sut.errorLabel.text = ""
        sut.viewModel.fetchNextSearchPage(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertEqual(sut.errorLabel.text, NSLocalizedString(TextConstants.kNoGifsMatch, comment: "No GIFs match this search."))
            XCTAssertEqual(sut.errorLabel.isHidden, false)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: TestsConstants.timeLimitForResponse)
    }
}
