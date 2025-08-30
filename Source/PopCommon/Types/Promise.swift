
public class Promise<T>
{
	public private(set) var result : T? = nil
	public private(set) var error : Error? = nil
	
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

public class TaskWithPromise<T> : Promise<T>
{
	private var taskWrapper : Task<Void,Never>!
	
	public init(detachedPriority:TaskPriority?=nil,theTask:@escaping () async throws->T) 
	{
		super.init()
		
		if let detachedPriority
		{
			self.taskWrapper = Task.detached(priority: detachedPriority)
			{
				await self.Run(theTask: theTask)
			}
		}
		else
		{
			self.taskWrapper = Task
			{
				await Run(theTask:theTask)
			}
		}
	}
	
	private func Run(theTask:@escaping () async throws->T) async
	{
		do
		{
			let result = try await theTask()
			self.resolve(result)
		}
		catch
		{
			self.reject(error)
		}
	}
	
	deinit
	{
		taskWrapper.cancel()
	}
}

