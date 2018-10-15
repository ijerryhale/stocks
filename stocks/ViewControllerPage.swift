//	ViewControllerPage.swift
// Copyright (c) 2018 Jerry Hale
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//
//  Created by Jerry Hale on 5/18/18.

import UIKit

// MARK: PageViewController
class PageViewController: UIPageViewController
{
    private(set) lazy var page: [UIViewController] =
    {
		func instantiateViewController(_ name: String) -> UIViewController
		{
			return (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name))
		}

        //	view controllers shown in array order
        return [ instantiateViewController("ViewControllerPivot"), instantiateViewController("ViewControllerBorrow")]
    }()

    weak var pageviewcontrollerdelegate: PageViewControllerDelegate?

	func scrollToNextViewController()
	{
		if let currentViewController = viewControllers?.first,
			let nextViewController = pageViewController(self, viewControllerAfter: currentViewController)
		{
			scrollToViewController(nextViewController)
		}
	}

	//	- parameter viewController: the view controller to show.
    private func scrollToViewController(_ viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward)
    {
        setViewControllers([viewController], direction: direction, animated: true, completion:
		{
			(finished) -> Void in
                // Setting the view controller programmatically does not fire
                // any delegate methods, so we have to manually notify the
                // 'tutorialDelegate' of the new index.
			if let firstViewController = self.viewControllers?.first,
				let index = self.page.index(of: firstViewController)
				{
					self.pageviewcontrollerdelegate?.didUpdatePageIndex(index)
				}
        })
    }

	//	MARK: UIViewController overrides
    override func viewDidLoad()
    { super.viewDidLoad(); print("PageViewController viewDidLoad")
		
        dataSource = self
        delegate = self
		
        if let viewController = page.first { scrollToViewController(viewController) }
		
       pageviewcontrollerdelegate?.didUpdatePageCount(page.count)
    }
}

// MARK: UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource
{
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
	{
		guard let index = page.index(of: viewController) else { return (nil) }
		
		//	user is on the first view controller and
		//	swiped left to loop to the last view controller
		guard (index - 1) > -1 else { return page.last }
		guard page.count > (index - 1) else { return (nil) }
		
		return (page[(index - 1)])
    }

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
	{
		guard let index = page.index(of: viewController) else { return (nil) }

		let pageCount = page.count
		
		//	user is on the last view controller and swiped
		//	right to loop to the first view controller
		guard pageCount != (index + 1) else { return page.first }
		guard pageCount > (index + 1) else { return (nil) }
		
		return (page[(index + 1)])
    }
}

// MARK: UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate
{
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
							previousViewControllers: [UIViewController], transitionCompleted completed: Bool)

	{
		if let viewController = viewControllers?.first,
			let index = page.index(of: viewController) { pageviewcontrollerdelegate?.didUpdatePageIndex(index) }
	}
}

// MARK: PageViewControllerDelegate
protocol PageViewControllerDelegate: class
{
	//	called when the number of pages is updated.
	//	- parameter count: the total number of pages.
    func didUpdatePageCount(_ count: Int)
	
	//	called when the current index is updated.
	//	- parameter index: the index of the currently visible page.
	func didUpdatePageIndex(_ index: Int)
}

// MARK: ViewControllerPage
class ViewControllerPage: UIViewController
{
   var pageViewController: PageViewController?
    {
        didSet { pageViewController?.pageviewcontrollerdelegate = self }
    }

    @IBOutlet weak var pageControl: UIPageControl!

	//	MARK: UIViewController overrides
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if let pageViewController = segue.destination as? PageViewController { self.pageViewController = pageViewController }
    }

	@IBAction func pageControlClick(_ sender: UIPageControl) { pageViewController?.scrollToNextViewController() }

	override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning(); print("ViewControllerPage didReceiveMemoryWarning") }

	override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerPage viewDidLoad") }
}

extension ViewControllerPage: PageViewControllerDelegate
{
	func didUpdatePageCount(_ count: Int) { pageControl.numberOfPages = count }
    func didUpdatePageIndex(_ index: Int)
    {
    	pageControl.currentPage = index
		
		//	fade in the pageControl
		self.pageControl.alpha = 0.2

		UIView.animate(withDuration: 1.5) { self.pageControl.alpha = 1 }
	}
}
