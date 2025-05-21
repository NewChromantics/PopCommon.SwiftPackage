import SwiftUI


public struct TabbedView<TabData,TabKey:Hashable&Identifiable,ContentView: View,TabView: View,NoContentView: View> : View
{
	//	todo: make this dictionary type generic
	var tabData : [TabKey:TabData]
	var tabKeys : [TabKey]	{	Array(tabData.keys)	}
	@State var selectedTab : TabKey?
	var selectedTabValid : Bool	{	tabKeys.contains(where: {$0 == selectedTab})	}

	//	if nothing selected, use first key, if no keys, then still have to show null
	var activeTab : TabKey?
	{
		return selectedTabValid ? selectedTab! : tabData.first?.key
	}
	
	var hideTabsWhenOneOption = false

	@ViewBuilder var content: (_ tabKey:TabKey,_ tabContent:TabData) -> ContentView
	@ViewBuilder var tabView: (_ label:TabKey,_ isActive:Bool) -> TabView
	@ViewBuilder var noContentView: () -> NoContentView
	
	public init(tabData:[TabKey:TabData],hideTabsWhenOneOption: Bool=false,content:@escaping(_:TabKey,_:TabData)->ContentView, tabView:@escaping(_:TabKey,_:Bool)->TabView, noContentView: @escaping()->NoContentView)
	{
		self.content = content
		self.tabView = tabView
		self.noContentView = noContentView
		self.tabData = tabData
		self.selectedTab = selectedTab
		self.hideTabsWhenOneOption = hideTabsWhenOneOption
	}
	
	public var body: some View
	{
		if tabKeys.isEmpty
		{
			noContentView()
		}
		else if hideTabsWhenOneOption && tabKeys.count == 1
		{
			content( tabKeys[0], tabData[tabKeys[0]]! )
		}
		else
		{
			VStack(spacing:0)
			{
				//	show tabs
				HStack(spacing:0)
				{
					/*
					 //	show special tab when active selection bad
					 if !selectedTabValid
					 {
					 Tab("Invalid selection", true )
					 }
					 */
					ForEach(tabKeys)
					{
						tabKey in
						//let tabContent = tabData[tabKey]
						let isActiveTab = tabKey == activeTab
						tabView( tabKey, isActiveTab )
						#if !os(tvOS)
							.onTapGesture
						{
							selectedTab = tabKey
						}
						#endif
					}
				}
				
				//	show body
				let bodyData = activeTab != nil ? tabData[activeTab!] : nil
				if let bodyData
				{
					content( activeTab!, bodyData )
				}
			}
		}
	}
}


