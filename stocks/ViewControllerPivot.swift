//	ViewControllerPivot.swift
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

//	calculate three different types
//	of pivot points for a given stock
//	https://en.wikipedia.org/wiki/Pivot_point_(technical_analysis)

//	pivot point calculations use a
//	stock's high, low, and closing
//	price from the previous day

//	everything is done in the
//	getPivotPoints action method

//	data is provided by ALPHA VANTAGE
//	https://www.alphavantage.co

//	YOU HAVE TO REQUEST AN API KEY
//	FROM ALPHA VANTAGE TO CHANGE
//	_ANY_ OF THE ARGUMENTS TO
//	-(void)getAVDataIntraday:(NSString *)function
//		symbol:(NSString *)symbol
//		interval:(NSString *)interval
//		completion:(void (^)(NSDictionary *dict, NSError *error))block
//	OR
//	-(void)getAVDataDaily:(NSString *)symbol
//		completion:(void (^)(NSDictionary *dict, NSError *error))block

//	MARK: ViewControllerPivot
class ViewControllerPivot: UIViewController
{
	@IBOutlet weak var symbol: UITextField!
	
	@IBOutlet weak var activityindicator: UIActivityIndicatorView!
	
	@IBOutlet weak var open: UILabel!
	@IBOutlet weak var high: UILabel!
	@IBOutlet weak var low: UILabel!
	@IBOutlet weak var close: UILabel!
	
	@IBOutlet weak var p_r3: UILabel!
	@IBOutlet weak var p_r2: UILabel!
	@IBOutlet weak var p_r1: UILabel!
	@IBOutlet weak var p_pivot: UILabel!
	@IBOutlet weak var p_s1: UILabel!
	@IBOutlet weak var p_s2: UILabel!
	@IBOutlet weak var p_s3: UILabel!
	
	@IBOutlet weak var f_r3: UILabel!
	@IBOutlet weak var f_r2: UILabel!
	@IBOutlet weak var f_r1: UILabel!
	@IBOutlet weak var f_pivot: UILabel!
	@IBOutlet weak var f_s1: UILabel!
	@IBOutlet weak var f_s2: UILabel!
	@IBOutlet weak var f_s3: UILabel!

	@IBOutlet weak var c_r4: UILabel!
	@IBOutlet weak var c_r3: UILabel!
	@IBOutlet weak var c_r2: UILabel!
	@IBOutlet weak var c_r1: UILabel!
	@IBOutlet weak var c_s1: UILabel!
	@IBOutlet weak var c_s2: UILabel!
	@IBOutlet weak var c_s3: UILabel!
	@IBOutlet weak var c_s4: UILabel!

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

					self.p_r3.text = String(format:"%.3f", p[.R3]!)
					self.p_r2.text = String(format:"%.3f", p[.R2]!)
					self.p_r1.text = String(format:"%.3f", p[.R1]!)

					self.p_pivot.text = String(format:"%.3f", p[.Pivot]!)

					self.p_s1.text = String(format:"%.3f", p[.S1]!)
					self.p_s2.text = String(format:"%.3f", p[.S2]!)
					self.p_s3.text = String(format:"%.3f", p[.S3]!)

					p = pivot.fibonacci()

					self.f_r3.text = String(format:"%.3f", p[.R3]!)
					self.f_r2.text = String(format:"%.3f", p[.R2]!)
					self.f_r1.text = String(format:"%.3f", p[.R1]!)

					self.f_pivot.text = String(format:"%.3f", p[.Pivot]!)

					self.f_s1.text = String(format:"%.3f", p[.S1]!)
					self.f_s2.text = String(format:"%.3f", p[.S2]!)
					self.f_s3.text = String(format:"%.3f", p[.S3]!)

					p = pivot.camarilla()

					self.c_r4.text = String(format:"%.3f", p[.R4]!)
					self.c_r3.text = String(format:"%.3f", p[.R3]!)
					self.c_r2.text = String(format:"%.3f", p[.R2]!)
					self.c_r1.text = String(format:"%.3f", p[.R1]!)

					self.c_s1.text = String(format:"%.3f", p[.S1]!)
					self.c_s2.text = String(format:"%.3f", p[.S2]!)
					self.c_s3.text = String(format:"%.3f", p[.S3]!)
					self.c_s4.text = String(format:"%.3f", p[.S4]!)
					
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

					self.p_r3.text = String(format:"%.3f", 0)
					self.p_r2.text = String(format:"%.3f", 0)
					self.p_r1.text = String(format:"%.3f", 0)

					self.p_pivot.text = String(format:"%.3f", 0)

					self.p_s1.text = String(format:"%.3f", 0)
					self.p_s2.text = String(format:"%.3f", 0)
					self.p_s3.text = String(format:"%.3f", 0)

					self.f_r3.text = String(format:"%.3f", 0)
					self.f_r2.text = String(format:"%.3f", 0)
					self.f_r1.text = String(format:"%.3f", 0)

					self.f_pivot.text = String(format:"%.3f", 0)

					self.f_s1.text = String(format:"%.3f", 0)
					self.f_s2.text = String(format:"%.3f", 0)
					self.f_s3.text = String(format:"%.3f", 0)

					self.c_r4.text = String(format:"%.3f", 0)
					self.c_r3.text = String(format:"%.3f", 0)
					self.c_r2.text = String(format:"%.3f", 0)
					self.c_r1.text = String(format:"%.3f", 0)

					self.c_s1.text = String(format:"%.3f", 0)
					self.c_s2.text = String(format:"%.3f", 0)
					self.c_s3.text = String(format:"%.3f", 0)
					self.c_s4.text = String(format:"%.3f", 0)
				}
			}
		}
	}

	//	MARK: UIViewController overrides
	override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning(); print("ViewControllerPivot didReceiveMemoryWarning") }

	override func viewDidLoad() { super.viewDidLoad(); print("ViewControllerPivot viewDidLoad"); symbol.delegate = self }
	
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

