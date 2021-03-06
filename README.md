# stocks

Right now this is pretty much just a shell I'm using to test some stuff in.

There is an attached XCode Playground which will compute sets of Pivot Points given high, low, and close stock prices.

Stock traders who trade on technical levels use these types of Pivot Point calculations to make decisions on when to buy or sell a particular stock.

This XCode project can serve as a template app for anything where AFNetworking is required. The AFNetworking layer is Objective C. Everything else is Swift 4.

## May 25, 2018

Delete original **stocks** GitHub repository.

Add custom UIPageControllerView and custom UIPageControl. Custom UIPageControl is at top of page rather than bottom of page. Create page which gets [**Interactive Brokers**](https://www.interactivebrokers.com/en/home.php) short sale list. Create page which contains the Pivot Point Storyboard from the original **stocks** repository.

Add UISearchBar to implement searching short sale list by Stock Symbol or Company Name.

## October 15, 2018

Update to XCode 10, Swift 4.2

## June 2, 2019

Update to Swift 5.

## June 17, 2019

Add contraints and Stack Views for Pivot Page. Rewrote some of ViewControllerPivot to make it easier to resize and move things around.

Still a bit of work to do on Pivot Points Page but this version handles multiple devices and rotation pretty well. 

## Requirements

- XCode 10+
- iOS 11+
- Swift 5+

![ibshortshares](https://cormya.com/image/_short_list_blue.png "Interactive Brokers Short Shares List") | ![symbolsearch](https://cormya.com/image/_symbol_search.png "Symbol Search") |
:-------------------------:|:-------------------------:
**Interactive Brokers Short Shares List** | **Symbol Search** |
![namesearch](https://cormya.com/image/_company_name_search.png "Name Search") | ![pivotpoints](https://cormya.com/image/_pivot_points.png  "Pivot Points") |
**Company Name Search** | **Fibonacci and Camarilla Pivot Points**

## May 28, 2018

Dump the old 90's looking greyscale UI and built Theme based UI. Add Table Footer.

![shortlistcherry](https://cormya.com/image/_short_list_cherry.png "Interactive Brokers Short Shares List") | ![shortlistaluminum](https://cormya.com/image/_short_list_aluminum.png "Symbol Search") |
:-------------------------:|:-------------------------:
**Cherry Theme** | **Aluminum Theme**

![symbolsearch](https://cormya.com/image/themecolors.png "Theme Colors")
