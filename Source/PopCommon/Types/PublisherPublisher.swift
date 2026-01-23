/*
 
	Make it a lot easier for an observable object to send out that a child/member has chaned


*/
import Foundation
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
		watch(obj, onChanged: 
				{
			self.OnWatchedChanged()
		})
	}
	
	//	@ObservedObject var thing : ObservableObjectThing
	//	watch(this,...)
	func watch<Object: ObservableObject>(_ obj: Object,onWillChange:@escaping()->Void)
	{
		let observer = obj.objectWillChange.sink 
		{ 
			_ in
			onWillChange()
		}
		publisherPublisherObservers.append(observer)
	}
	
	func watch<Object: ObservableObject>(_ obj: Object,onChanged:@escaping()->Void)
	{
		//	will change occurs before data updated - defer and then we can assume it has changed
		watch(obj,onWillChange:
		{
			DispatchQueue.main.async
			{
				onChanged()
			}
		})
	}
	
	//	@Published var thing : SomeThing
	//	watch(&_this,...)
	func watch<Value>(_ pub:inout Published<Value>)
	{
		watch(&pub)
		{
			_ in
			self.OnWatchedChanged() 
		}
	}
	
	func watch<Value>(_ pub:inout Published<Value>,onChangingTo:@escaping(Value)->Void)
	{
		let observer = pub.projectedValue.sink 
		{ 
			newValue in
			onChangingTo(newValue)
		}
		publisherPublisherObservers.append(observer)
	}
	
	func watch<Value>(_ pub:inout Published<Value>,onChanged:@escaping()->Void)
	{
		watch(&pub)
		{
			changingValueTo in
			//	instead of callback now, defer to when we [assume] actual data will be updated
			DispatchQueue.main.async
			{
				onChanged()
			}
		}
	}
	
	
	
	func watch<Value>(_ pub:Published<Value>.Publisher,onChangingTo:@escaping(Value)->Void)
	{
		let observer = pub.sink 
		{ 
			newValue in
			onChangingTo(newValue)
		}
		publisherPublisherObservers.append(observer)
	}
	
	
	func watch<Value>(_ pub:Published<Value>.Publisher,onChanged:@escaping()->Void)
	{
		watch(pub)
		{
			changingValueTo in
			//	instead of callback now, defer to when we [assume] actual data will be updated
			DispatchQueue.main.async
			{
				onChanged()
			}
		}
	}
}
