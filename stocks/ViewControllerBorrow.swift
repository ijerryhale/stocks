//	ViewControllerBorrow.swift
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
//  Created by Jerry Hale on 5/23/18.

class TableViewFooter: UIView
{
	let label: UILabel = UILabel()
	
	override public init(frame: CGRect) { super.init(frame: frame); configureView(); }
	required public init?(coder: NSCoder) { super.init(coder: coder); configureView(); }

	override func draw(_ rect: CGRect) { label.frame = bounds }

	func configureView()
	{
		backgroundColor = UIColor.themeColor(THEME_COLOR)
		alpha = 1.0
	
		//	configure label
		label.textAlignment = .center
		label.text = ""
		addSubview(label)
  }

  // MARK: - Animation
  fileprivate func hideFooter()
  {
		UIView.animate(withDuration: 0.7)
		{
			[unowned self] in
			self.alpha = 0.0
		}
	}

	fileprivate func showFooter()
	{
		UIView.animate(withDuration: 0.7)
		{
			[unowned self] in
			self.alpha = 1.0
		}
	}
}

extension TableViewFooter
{
	public func setNotFiltering()
	{
		label.text = ""
		hideFooter()
	}
	
	public func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int)
	{
		if (filteredItemCount == totalItemCount)
		{
			setNotFiltering()
		}
		else if (filteredItemCount == 0)
		{
			label.text = "No items match your query"
			showFooter()
		}
		else
		{
			label.text = "Displaying \(filteredItemCount) of \(totalItemCount)"
			showFooter()
		}
	}
}

//	MARK: ViewControllerBorrow
class ViewControllerBorrow: UIViewController
{
	enum element: Int { case ibb_SYM=0, ibb_CUR, ibb_NAME, ibb_CON, ibb_ISIN, ibb_REBATERATE, ibb_FEERATE, ibb_AVAILABLE }
	
	var selectedScopeBtnIndex = 0
	var filteredRowCount = 0

	var csvTable = Array<Array<String>>()
    var symbolSectionTitle = [String]()
	var symbolDictionary = [String: [Int]]()
	
	@IBOutlet weak var fileTime: UITextField!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var tableViewFooter: TableViewFooter!

	func handleNetworkError(error: Error?) { print("handleNetworkError: ", error as Any) }
	func handleNoDataAvailable(error: Error?) { print("handleNoDataAvailable: ", error as Any) }

	private func buildfiltereddataset(_ string: String) -> Bool
	{
		if string.isEmpty { return (false) }

		symbolSectionTitle.removeAll()
		symbolDictionary.removeAll()
		
		var hittest = false
		filteredRowCount = 0

		for i in 0..<csvTable.count
		{
			let symbol = csvTable[i][element.ibb_SYM.rawValue]
			var searchstr = symbol
	
			if selectedScopeBtnIndex == 1
			{ searchstr = csvTable[i][element.ibb_NAME.rawValue] }

			if !searchstr.starts(with: string) { continue }
			else
			{
				hittest = true

				let sectionTitle = String(symbol.prefix(1))

				if var symbolValue = symbolDictionary[sectionTitle]
				{
					symbolValue.append(i)
					filteredRowCount += 1
					symbolDictionary[sectionTitle] = symbolValue
				}
				else { symbolDictionary[sectionTitle] = [i]; filteredRowCount += 1 }
				
			}

			 symbolSectionTitle = [String](symbolDictionary.keys)
			 symbolSectionTitle =  symbolSectionTitle.sorted(by: { $0 < $1 })
		}
		
		return (hittest)
	}

	private func builddataset()
	{
		for i in 0..<csvTable.count
		{
			let sym = csvTable[i][element.ibb_SYM.rawValue]
			let sectionTitle = String(sym.prefix(1))

			if var symbolValue = symbolDictionary[sectionTitle]
			{
				symbolValue.append(i)
				symbolDictionary[sectionTitle] = symbolValue
			}
			else { symbolDictionary[sectionTitle] = [i] }
		}

		filteredRowCount = csvTable.count
		symbolSectionTitle = [String](symbolDictionary.keys)
		symbolSectionTitle =  symbolSectionTitle.sorted(by: { $0 < $1 })
	}
	
	//	MARK: getIBBorrowList Button Action
	@IBAction func getIBBorrowList(_ sender: Any)
	{
		//	1.	go to Interactive Brokers and get
		//		the list of shortable shares
		//	2.	parse the returned CSV file and
		//		build an array of dictionaries
		//	4.	build a UITableView from that array
		
		searchBar.text = ""

		DispatchQueue.main.async /* update UI on main thread */
		{ self.activityIndicator.startAnimating() }

		DataAccess().getIB_BorrowList("usa.txt")
		{
			(csvtable, error) in

			if (error == nil)
			{
				//	[0] - #BOF <file date, file time>
				//	[1] - Field Names
				//	[n] - line [n] containing eight Fields
				//	[last] - #EOF <number of rows>

				//	Field Names
				//	"#SYM"
				//	"CUR"
				//	"NAME"
				//	"CON"
				//	"ISIN"
				//	"REBATERATE"
				//	"FEERATE"
				//	"AVAILABLE"
				//	""
				//	value at index[n] in csvtable contains
				//	array of fields of line[n] of csv file
				//	self.csvtable.forEach { line in print(line) }

				//	get the beginning of file
				//	marker and then delete
				let bof = csvtable![0] as! [String]
				var filetime = bof[1]
				filetime += " "
				filetime += bof[2]
				
				self.csvTable = csvtable as! Array<Array<String>>
				self.csvTable.remove(at: 0)
				self.csvTable.remove(at: 0)
				self.csvTable.remove(at: self.csvTable.count - 1)
				
				self.builddataset()
				self.tableView.reloadData()

				self.tableView.sectionIndexColor = nil
				
				DispatchQueue.main.async /* update UI on main thread */
				{ self.fileTime.text = filetime; self.activityIndicator.stopAnimating() }
			}
			else { self.handleNetworkError(error: error); }
		}
	}
	
	func isFiltering() -> Bool
	{
		if searchBar.text!.isEmpty { return (true) }

		return (csvTable.count != filteredRowCount)
	}

	//	MARK: UIViewController overrides
	override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning(); print("ViewControllerBorrow didReceiveMemoryWarning") }

	override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerBorrow viewDidLoad")
	
		searchBar.autocapitalizationType = .allCharacters

		let image = UIImage()

		searchBar.setBackgroundImage(image, for: .any, barMetrics: .default)
		searchBar.scopeBarBackgroundImage = image

		tableView.delegate = self
        tableView.dataSource = self
	
        tableView.register(UINib(nibName: VALUE_ROW_CELL, bundle: nil), forCellReuseIdentifier: VALUE_ROW_CELL)

		getIBBorrowList(Int())
	 }
}

// MARK: - UISearchBar Delegate
extension ViewControllerBorrow: UISearchBarDelegate
{
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
	{
		if buildfiltereddataset(searchText) == false
		{
			builddataset()
			tableView.scrollToRow(at: [0, NSNotFound], at: .top, animated: true)
		}

		tableView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
	{
		if selectedScopeBtnIndex != selectedScope
		{
			selectedScopeBtnIndex = selectedScope
			self.searchBar(searchBar, textDidChange: searchBar.text!)
			tableView.scrollToRow(at: [0, NSNotFound], at: .top, animated: true)
		}
	}
}

//	MARK: UITableView Datasource Methods
extension ViewControllerBorrow : UITableViewDataSource
{
	func numberOfSections(in tableView: UITableView) -> Int { return (symbolSectionTitle.count) }
	func sectionIndexTitles(for tableView: UITableView) -> [String]? { return (symbolSectionTitle) }
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		let symbolKey = symbolSectionTitle[section]
		if let symbolValue = symbolDictionary[symbolKey]
		{
			if isFiltering()
			{
				tableViewFooter.setIsFilteringToShow(filteredItemCount: filteredRowCount, of: csvTable.count)
			}
			else { tableViewFooter.setNotFiltering() }
			
			return (symbolValue.count)
		}
 
		return (0)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		guard csvTable.count > 0 else { return (UITableViewCell()) }
		
		let	cell = tableView.dequeueReusableCell(withIdentifier:VALUE_ROW_CELL, for: indexPath)
		let sectionTitle = symbolSectionTitle[indexPath.section]
		let linenumber = (symbolDictionary[sectionTitle])![indexPath.row]

		let rowcell = cell as! RowCell
		rowcell.sym.text = csvTable[linenumber][element.ibb_SYM.rawValue]
		rowcell.name.text = csvTable[linenumber][element.ibb_NAME.rawValue]
		
		
		rowcell.isin.text = csvTable[linenumber][element.ibb_ISIN.rawValue]
		rowcell.available.text = csvTable[linenumber][element.ibb_AVAILABLE.rawValue]
		
		rowcell.feerate.text = csvTable[linenumber][element.ibb_FEERATE.rawValue]
		rowcell.rebaterate.text = csvTable[linenumber][element.ibb_REBATERATE.rawValue]
		
		return (cell)
    }
}

//	MARK: UITableView Delegate Methods
extension ViewControllerBorrow : UITableViewDelegate
{
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
	{
		let view = UIView()
		
		view.layer.backgroundColor = UIColor.themeColor(THEME_COLOR).cgColor;

		let label = UILabel()
		
		label.font = UIFont(name:"Arial Bold", size:12)
		label.text = symbolSectionTitle[section]
		label.frame = CGRect(x: 18, y: 5, width: 100, height: 35)
		view.addSubview(label)
		
		return (view)
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return (40.0) }
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return (0.0) }
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return (104
	) }
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { print("tableVies.didSelectRow") }
}
