//
//  Constants.swift
//  SBTestTask
//
//  Created by Alex2 on 3/31/19.
//  Copyright © 2019 Alex Shekunsky. All rights reserved.
//


struct AnimationsConstants {
    static let animatorsTransitionDuration  = 0.5
    static let collectionViewLayerSpeed: Float = 0.7
}

struct FetchGifsConstants {
    static let pageSize  = 25
    static let fetchTimerDelay  = 0.75
    
    /// The maximum allowed size for gifs shown in the feed
    static let maxSizeInBytes: Int = 0 //  (but for now - returned all sizes)
}
    
struct MemoryPerfomanceConstants {
    static let maxCacheAge = 3600 * 24 * 7 //1 Week
    static let maxMemoryCost: UInt = 1024 * 1024 * 100 //Aprox 100 images
}

struct UIConstants {
    static let searchControllerHeight: CGFloat = 44.0
}

struct TextConstants {
    static let kMainScreenTitle = "Giphy"
    static let kSearchPlaceholder = "Search GIFs"
    static let kTextForStartSearch = "Please enter gif name to start search."
    static let kNoGifsMatch = "No GIFs match this search."
}

struct TestsConstants {
    static let timeLimitForResponse = 20.0
    static let pageLimit  = 25
    static let requestForEmptyResponse = "!"
}
