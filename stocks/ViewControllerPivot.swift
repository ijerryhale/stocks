//	ViewControllerPivot.swift
// Copyright (c) 2019 Jerry Hale
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

//	calculate three different types
//	of pivot points for a given stock
//	https://en.wikipedia.org/wiki/Pivot_point_(technical_analysis)

//	MARK: ViewControllerPivot
class ViewControllerPivot: UIViewController
{
	@IBOutlet weak var activityindicator: UIActivityIndicatorView!
	
    @IBOutlet weak var symbol: UITextField!
    
    @IBOutlet weak var open: UILabel!
	@IBOutlet weak var high: UILabel!
	@IBOutlet weak var low: UILabel!
	@IBOutlet weak var close: UILabel!
  
    @IBOutlet weak var pivotStackView: UIStackView!
    @IBOutlet weak var fibStackView: UIStackView!
    @IBOutlet weak var camStackView: UIStackView!

    var pivotPoints: [PivotRowView] = []
    var fibPoints: [PivotRowView] = []
    var camarillaPoints: [PivotRowView] = []

    func handleNetworkError(error: Error?) { print("handleNetworkError: ", error as Any) }
	func handleNoDataAvailable(error: Error?) { print("handleNoDataAvailable: ", error as Any) }

	//	MARK: getPivotPoints Button Action
	@IBAction func getPivotPoints(_ sender: UIButton)
	{
		//	pretty much everything is done
		//	inside this button action
		
		//	1.	get the daily stock info for the stock symbol
		//	2.	find the OHLC info for either yesterday
		//		or whenever the market was open last
		//	3.	compute the three different types of
		//		pivot points
		//	4.	fill in the UI values
		
		//	get the stock symbol
		let symbol = self.symbol.text ?? ""

		if symbol.count < 1 { return }

		//	MARK: _pivot: calculate pivot points, return pivot point dictionary
        struct _pivot
        {
            enum element: String { case R4="R4",R3="R3",R2="R2",R1="R1",Pivot="Pivot",S1="S1",S2="S2",S3="S3",S4="S4" }

            let high : Double
            let low : Double
            let close : Double

            let pivot : Double

            init(_ high: Double, low: Double, close: Double)
            {
                self.high = high
                self.low = low
                self.close = close

                /* PP = (H + L + C) / 3 */
                self.pivot = (high + low + close) / 3.00
            }

            func standard() -> [element : Double]
            {
                /* R1 = 2×PP - L */
                let r1 = (2 * pivot) - low

                /* R2 = PP + (H - L) */
                let r2 = pivot + (high - low)

                /* R3 = H + 2 * (PP - L) */
                let r3 = high + 2 * (pivot - low)

                /* S1 = 2×PP− - H */
                let s1 = (2 * pivot) - high

                /* S2 = PP - (H - L) */
                let s2 = pivot - (r1 - s1)

                /* S3 = L - 2 * (H - PP) */
                let s3 = low - 2 * (high - pivot)

                print("\nPivot Points")
                print("R3:    ", r3); print("R2:    ", r2); print("R1:    ", r1)
                print("Pivot: ", pivot)
                print("S1:    ", s1); print("S2:    ", s2); print("S3:    ", s3)

                return ([.R3: r3, .R2: r2, .R1: r1, .Pivot: pivot, .S1: s1, .S2: s2, .S3: s3])
            }

            func fibonacci() -> [element : Double]
            {
                /* calc Fibonacci pivot points */
                let r3 = pivot + ((high - low) * 1.000)
                let r2 = pivot + ((high - low) * 0.618)
                let r1 = pivot + ((high - low) * 0.382)

                let s1 = pivot - ((high - low) * 0.382)
                let s2 = pivot - ((high - low) * 0.618)
                let s3 = pivot - ((high - low) * 1.000)

                print("\nFibonacci Pivot Points")
                print("Fib R3: ", r3); print("Fib R2: ", r2); print("Fib R1: ", r1)
                print("Pivot:  ", pivot)
                print("Fib S1: ", s1); print("Fib S2: ", s2); print("Fib S3: ", s3);

                return ([.R3: r3, .R2: r2, .R1: r1, .Pivot: pivot, .S1: s1, .S2: s2, .S3: s3])
            }

            func camarilla() -> [element : Double]
            {
                /* calc Camarilla pivot points */
                let r4 = close + (high - low) * 1.1 / 2
                let r3 = close + (high - low) * 1.1 / 4
                let r2 = close + (high - low) * 1.1 / 6
                let r1 = close + (high - low) * 1.1 / 12

                let s1 = close - (high - low) * 1.1 / 12
                let s2 = close - (high - low) * 1.1 / 6
                let s3 = close - (high - low) * 1.1 / 4
                let s4 = close - (high - low) * 1.1 / 2

                print("\nCamarilla Pivot Points")
                print("Break Out Long:  ", r4); print("Short:           ", r3); print("HL2:             ", r2); print("HL1:             ", r1)
                print("LL1:             ", s1); print("LL2:             ", s2); print("Long:            ", s3); print("Break Out Short: ", s4)

                return ([.R4: r4, .R3: r3, .R2: r2, .R1: r1, .Pivot: pivot, .S1: s1, .S2: s2, .S3: s3, .S4: s4])
            }
        }

		let dateFormatter = DateFormatter()

		dateFormatter.dateFormat = "yyyy-MM-dd"
		dateFormatter.timeZone = TimeZone.current

		self.activityindicator.startAnimating()

		DataAccess().getOHLCData(symbol)
		{
			(dict, error) in

            if error == nil
            {
                DispatchQueue.main.async /* update UI on main thread */
                {
                    let ohlc = dict as! [String : Any]

                    let open:Double = ohlc[KEY_OPEN] as! Double
                    let high:Double = ohlc[KEY_HIGH] as! Double
                    let low:Double = ohlc[KEY_LOW] as! Double
                    let close:Double = ohlc[KEY_CLOSE] as! Double

                    let pivot = _pivot(high, low: low, close: close)

                    var p = pivot.standard()

                    self.open.text = String(format:"%.3f", open)
                    self.high.text = String(format:"%.3f", high)
                    self.low.text = String(format:"%.3f", low)
                    self.close.text = String(format:"%.3f", close)
                    
                    self.pivotPoints[0].value.text = String(format:"%.3f", p[.R3]!)
                    self.pivotPoints[1].value.text = String(format:"%.3f", p[.R2]!)
                    self.pivotPoints[2].value.text = String(format:"%.3f", p[.R1]!)
                    
                    self.pivotPoints[3].value.text = String(format:"%.3f", p[.Pivot]!)
                    
                    self.pivotPoints[4].value.text = String(format:"%.3f", p[.S1]!)
                    self.pivotPoints[5].value.text = String(format:"%.3f", p[.S2]!)
                    self.pivotPoints[6].value.text = String(format:"%.3f", p[.S3]!)


                    p = pivot.fibonacci()
                    
                    self.fibPoints[0].value.text = String(format:"%.3f", p[.R3]!)
                    self.fibPoints[1].value.text = String(format:"%.3f", p[.R2]!)
                    self.fibPoints[2].value.text = String(format:"%.3f", p[.R1]!)
                    
                    self.fibPoints[3].value.text = String(format:"%.3f", p[.Pivot]!)
                    
                    self.fibPoints[4].value.text = String(format:"%.3f", p[.S1]!)
                    self.fibPoints[5].value.text = String(format:"%.3f", p[.S2]!)
                    self.fibPoints[6].value.text = String(format:"%.3f", p[.S3]!)

                    p = pivot.camarilla()

                    self.camarillaPoints[0].value.text = String(format:"%.3f", p[.R4]!)
                    self.camarillaPoints[1].value.text = String(format:"%.3f", p[.R3]!)
                    self.camarillaPoints[2].value.text = String(format:"%.3f", p[.R2]!)
                    self.camarillaPoints[3].value.text = String(format:"%.3f", p[.R1]!)
                    
                    self.camarillaPoints[3].value.text = String(format:"%.3f", p[.Pivot]!)
                    
                    self.camarillaPoints[4].value.text = String(format:"%.3f", p[.S1]!)
                    self.camarillaPoints[5].value.text = String(format:"%.3f", p[.S2]!)
                    self.camarillaPoints[6].value.text = String(format:"%.3f", p[.S3]!)
                    self.camarillaPoints[7].value.text = String(format:"%.3f", p[.S4]!)

                    self.activityindicator.stopAnimating()
                }
            }
            else
            {
                self.handleNetworkError(error: error);
                DispatchQueue.main.async /* update UI on main thread */
                {
                    self.activityindicator.stopAnimating()
                    self.open.text = String(format:"%.3f", 0)
                    self.high.text = String(format:"%.3f", 0)
                    self.low.text = String(format:"%.3f", 0)
                    self.close.text = String(format:"%.3f", 0)
                    
                    self.pivotPoints[0].value.text = String(format:"%.3f", 0)
                    self.pivotPoints[1].value.text = String(format:"%.3f", 0)
                    self.pivotPoints[2].value.text = String(format:"%.3f", 0)
                    self.pivotPoints[3].value.text = String(format:"%.3f", 0)
                    self.pivotPoints[4].value.text = String(format:"%.3f", 0)
                    self.pivotPoints[5].value.text = String(format:"%.3f", 0)
                    self.pivotPoints[6].value.text = String(format:"%.3f", 0)
                    
                    self.fibPoints[0].value.text = String(format:"%.3f", 0)
                    self.fibPoints[1].value.text = String(format:"%.3f", 0)
                    self.fibPoints[2].value.text = String(format:"%.3f", 0)
                    self.fibPoints[3].value.text = String(format:"%.3f", 0)
                    self.fibPoints[4].value.text = String(format:"%.3f", 0)
                    self.fibPoints[5].value.text = String(format:"%.3f", 0)
                    self.fibPoints[6].value.text = String(format:"%.3f", 0)
                    
                    self.camarillaPoints[0].value.text = String(format:"%.3f", 0)
                    self.camarillaPoints[1].value.text = String(format:"%.3f", 0)
                    self.camarillaPoints[2].value.text = String(format:"%.3f", 0)
                    self.camarillaPoints[3].value.text = String(format:"%.3f", 0)
                    self.camarillaPoints[3].value.text = String(format:"%.3f", 0)
                    self.camarillaPoints[4].value.text = String(format:"%.3f", 0)
                    self.camarillaPoints[5].value.text = String(format:"%.3f", 0)
                    self.camarillaPoints[6].value.text = String(format:"%.3f", 0)
                    self.camarillaPoints[7].value.text = String(format:"%.3f", 0)
                }
            }
		}
	}

	//	MARK: UIViewController overrides
	override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning(); print("ViewControllerPivot didReceiveMemoryWarning") }
    
    override func viewDidLoad()
    { super.viewDidLoad(); print("ViewControllerPivot viewDidLoad");
        
        symbol.delegate = self
        addPivotPointsSubviews()
    }

    func addPivotPointsSubviews()
    {
        //  create the PivotHeaderView and add to StackView
        var pivotHeaderView = UINib(nibName: "PivotHeaderView", bundle: nil).instantiate(withOwner: nil,
                                                                                         options: nil)[0] as! PivotHeaderView
        pivotHeaderView.name.text = "Pivot Points"
        
        pivotStackView.addArrangedSubview(pivotHeaderView)
        
        //  create the PivotRowViews and add to StackView
        pivotPoints = (0 ..< 7).map { (_) -> PivotRowView in
            return UINib(nibName: "PivotRowView", bundle: nil).instantiate(withOwner: nil,
                                                                        options: nil)[0] as! PivotRowView }
        pivotPoints[0].name.text = "R3:"
        pivotPoints[1].name.text = "R2:"
        pivotPoints[2].name.text = "R1:"
        pivotPoints[3].name.text = "Pivot:"
        pivotPoints[4].name.text = "S1:"
        pivotPoints[5].name.text = "S2:"
        pivotPoints[6].name.text = "S3:"
 
        pivotPoints.forEach { (view) in pivotStackView.addArrangedSubview(view) }

        //  Fibonacci Pivot Points
        pivotHeaderView = UINib(nibName: "PivotHeaderView", bundle: nil).instantiate(withOwner: nil,
                                                                                         options: nil)[0] as! PivotHeaderView
        pivotHeaderView.name.text = "Fibonacci Pivot Points"
        
        fibStackView.addArrangedSubview(pivotHeaderView)
        
        //  create the PivotRowViews and add to StackView
        fibPoints = (0 ..< 7).map { (_) -> PivotRowView in
            return UINib(nibName: "PivotRowView", bundle: nil).instantiate(withOwner: nil,
                                                                           options: nil)[0] as! PivotRowView }
        fibPoints[0].name.text = "R3:"
        fibPoints[1].name.text = "R2:"
        fibPoints[2].name.text = "R1:"
        fibPoints[3].name.text = "Pivot:"
        fibPoints[4].name.text = "S1:"
        fibPoints[5].name.text = "S2:"
        fibPoints[6].name.text = "S3:"
        
        fibPoints.forEach { (view) in fibStackView.addArrangedSubview(view) }
        
        //  Camarilla Pivot Points
        pivotHeaderView = UINib(nibName: "PivotHeaderView", bundle: nil).instantiate(withOwner: nil,
                                                                                         options: nil)[0] as! PivotHeaderView
        pivotHeaderView.name.text = "Camarilla Pivot Points"
        
        camStackView.addArrangedSubview(pivotHeaderView)

        //  create the PivotRowViews and add to StackView
        camarillaPoints = (0 ..< 8).map { (_) -> PivotRowView in
            return UINib(nibName: "PivotRowView", bundle: nil).instantiate(withOwner: nil,
                                                                           options: nil)[0] as! PivotRowView }
        camarillaPoints[0].name.text = "Break Out Long:"
        camarillaPoints[1].name.text = "Short:"
        camarillaPoints[2].name.text = "HL2:"
        camarillaPoints[3].name.text = "HL1:"
        camarillaPoints[4].name.text = "LL2:"
        camarillaPoints[5].name.text = "LL1:"
        camarillaPoints[6].name.text = "Long:"
        camarillaPoints[7].name.text = "Break Out Short:"

        camarillaPoints.forEach { (view) in camStackView.addArrangedSubview(view) }
    }
}

extension ViewControllerPivot : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
		let currentText = textField.text ?? ""
		guard let stringRange = Range(range, in: currentText) else { return false }

		let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
		
		return (updatedText.count < 7)
    }
}

