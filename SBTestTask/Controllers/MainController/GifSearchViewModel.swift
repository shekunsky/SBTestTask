//
//  GifSearchViewModel.swift
//  SBTestTask
//
//  Created by Alex2 on 3/30/19.
//  Copyright © 2019 Alex Shekunsky. All rights reserved.
//

import Foundation
class GifSearchViewModel {
    
    //MARK: Vars
    internal var searchText = ""
    internal var latestSearchResponse: GiphyMultipleGIFResponse?
    
    internal var currentGifs: [GiphyItem] = [GiphyItem](){
        didSet {
            resultsListChangedClosure!()
        }
    }
    
    internal var widthOfCollectionView: CGFloat = 0.0
    
    internal var currentSearchPageOffset: Int = 0
    
    internal var searchCounter: Int = 0
    
    internal var isSearchPageLoadInProgress: Bool = false
    
    internal var searchCoalesceTimer: Timer? {
        willSet {
            if searchCoalesceTimer?.isValid == true
            {
                searchCoalesceTimer?.invalidate()
            }
        }
    }
    
    internal var startLoadingClosure: (()->())?
    internal var stopLoadingClosure: (()->())?
    internal var resultsListChangedClosure: (()->())?
    internal var showErrorClosure: ((_ error: String)->())?
    
    public var contentRating: SwiftyGiphyAPIContentRating = .pg13
    
    public var allowResultPaging: Bool = true
    
    //MARK: - Functions
    func bindModelFor(width: CGFloat) {
        widthOfCollectionView = width
    }
    
    func fetchNextSearchPage(_ isForScroll: Bool)
    {
        guard !isSearchPageLoadInProgress else {
            return
        }
        if let flag = searchCoalesceTimer?.isValid, flag == true {
            return
        }
        guard  searchText.count > 0 else {
            
            self.searchCounter += 1
            self.currentGifs = []
            return
        }
        let timeInterval = isForScroll ? 0.0 : FetchGifsConstants.fetchTimerDelay
        searchCoalesceTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, block: { [unowned self] () -> Void in
            
            self.isSearchPageLoadInProgress = true
            if self.currentGifs.count >= 0
            {
                self.startLoadingClosure!()
            }
            
            self.searchCounter += 1
            let currentCounter = self.searchCounter
            
            SwiftyGiphyAPI.shared.getSearch(searchTerm: self.searchText,
                                            limit: FetchGifsConstants.pageSize,
                                            rating: self.contentRating,
                                            offset: self.currentSearchPageOffset) { [weak self] (error, response) in
                
                self?.isSearchPageLoadInProgress = false
                self?.stopLoadingClosure!()
                guard currentCounter == self?.searchCounter else {
                    self?.fetchNextSearchPage(false)
                    return
                }
                guard error == nil else {
                    
                    if self?.currentGifs.count == 0
                    {
                        self?.showErrorClosure!(error?.localizedDescription ?? "Error")
                    }
                    
                    print("Giphy error: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                self?.latestSearchResponse = response
                self?.currentGifs.append(contentsOf: response!.gifsSmallerThan(sizeInBytes: FetchGifsConstants.maxSizeInBytes, forWidth: (self?.widthOfCollectionView)!))
                
                self?.currentSearchPageOffset = (response!.pagination?.offset ?? (self?.currentSearchPageOffset ?? 0)) + (response!.pagination?.count ?? 0)
                
                if self?.currentGifs.count == 0
                {
                    self?.showErrorClosure!(NSLocalizedString(TextConstants.kNoGifsMatch, comment: "No GIFs match this search."))
                }
            }
            }, repeats: false) as! Timer?
        if isForScroll {
            let runLoop = RunLoop.current
            runLoop.add(searchCoalesceTimer!, forMode: RunLoop.Mode.default)
            runLoop.run()
        }
    }
    
    func destroyCurrentResults() {
        searchCounter += 1
        latestSearchResponse = nil
        currentSearchPageOffset = 0
        currentGifs = [GiphyItem]()
    }
    
}
