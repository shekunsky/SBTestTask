# SBTestTask

A photo viewer app which fetches GIFs from a https://giphy.com/ service. On first screen you can search GIFs by name and change layout. When you will tap on some photo - next screen will be presented with large photo. On this screen you can share selected GIF.


### Used technologies:

1. **Swift 5.0**

2. **Xcode 10.2**

3. **Supported IOS:**  9.0+

4. **Supported devices:**  iPhone4s+

5. **The main screen is implemented using MVVM**


### Used 3-party libraries:

1. **FLAnimatedImage** - for presenting animated GIF

2. **SwiftyGiphy** - API for GIPHY service

3. **ObjectMapper**  - map response from API to model

4. **SDWebImage**  - load and cashe GIF-images


### Unit testing:
Unit tests placed in **<SBTestTaskTests.swift>** file

1. **testAPIWorking()** - test that API result for search text "cat" will be received in expected time (timeLimitForResponse = 20.0)

2. **testResponsePagination()** - test that API will give expected number or results (pageLimit = 25) for search text "cat"

3. **testAPIForEmptyResponse()**  - test that API will retutn 0 results and no error for search text "!"

4. **testEmptyResponseResult()**  - test that info label will be shown with text "No GIFs match this search." for search text "!"


## Installing
For open project you need Xcode version 10.2 or higher. 
1. Open **<SBTestTask.xcodeproj>** file in Xcode.
2. At the SBTestTask target general settings page set your development team.
3. Select device (or simulator) on which you want to install the App.
4. Build and Run.
