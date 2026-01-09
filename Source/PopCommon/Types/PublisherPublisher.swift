/*
 
	Make it a lot easier for an observable object to send out that a child/member has chaned


*/

import Combine


public protocol PublisherPublisher: ObservableObject 
{
	var publisherPublisherObservers: [AnyCancellable] { get set }
	func OnWatchedChanged()		//	self.objectWillChange.send()
}

public extension PublisherPublisher
{
	//	defaults for when using a non specific callback
	func OnWatchedChanged() 
	{
		print("Watched object changed and not handled")
	}
}


public extension PublisherPublisher
{
	func watch<Object: ObservableObject>(_ obj: Object)
	{
		watch(obj)
		{
			self.OnWatchedChanged()
		}
	}
	
	func watch<Object: ObservableObject>(_ obj: Object,onWillChange:@escaping()->Void)
	{
		let observer = obj.objectWillChange.sink 
		{ 
			_ in
			onWillChange()
		}
		publisherPublisherObservers.append(observer)
	}
	
	func watch<Value>(_ pub:inout Published<Value>)
	{
		watch(&pub)
		{
			_ in
			self.OnWatchedChanged() 
		}
	}
	
	func watch<Value>(_ pub:inout Published<Value>,onChanged:@escaping(Value)->Void)
	{
		let observer = pub.projectedValue.sink 
		{ 
			newValue in
			onChanged(newValue)
		}
		publisherPublisherObservers.append(observer)
	}
}
