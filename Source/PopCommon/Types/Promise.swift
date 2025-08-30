
public class Promise<T>
{
	var result : T? = nil
	var error : Error? = nil
	public var isResolved : Bool 
	{
		return (result != nil) || (error != nil)
	}
	
	public init()
	{
	}
	
	//	returns nil if not yet resovled
	public func GetResult() throws -> T?
	{
		if let error 
		{
			throw error
		}
		return result
	}
	
	public func WaitAsTask() -> Task<T,Error>
	{
		return Task
		{
			return try await Wait()
		}
	}
	
	public func Wait() async throws -> T
	{
		//	spin! yuck!
		while ( true )
		{
			//	throws when task cancelled
			try await Task.sleep(nanoseconds: 1_000_000)
			if let result
			{
				return result
			}
			if let error
			{
				throw error
			}
		}
	}
	
	public func resolve(_ value:T)
	{
		result = value
	}
	
	public func reject(_ exception:Error)
	{
		error = exception
	}
}
