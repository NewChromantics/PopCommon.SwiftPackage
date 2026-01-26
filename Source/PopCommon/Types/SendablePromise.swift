/*
 
	A simple wrapper for futures which acts more like a promise,
	but is also sendable to be used across isolations.
 
	This may still need a lock to be threadsafe.
 
*/
import Combine


@available(macOS 12.0, *)
public class SendablePromise<Result> : @unchecked Sendable
{
	private var finishedPromise : Future<Result,Error>.Promise!
	private var finishedFuture : Future<Result,Error>!
	
	//	special introspection
	//	gr: should be an enum
	public var isErrored : Bool { hasError != nil }
	public private(set) var hasError : Error? = nil	
	public private(set) var isResolved : Bool = false
	
	public init()
	{
		self.finishedFuture = Future<Result,Error>()
		{
			promise in
			self.finishedPromise = promise
		}
	}
	
	@available(*, deprecated, renamed: "value", message: "Wait() here for transition from GrahamsPromise to SendablePromise")
	public func Wait() async throws -> Result
	{
		return try await value
	}
	
	public var value : Result
	{
		get async throws 
		{
			return try await finishedFuture.value
		}
	}
	
	public func Resolve(_ value:Result)
	{
		self.isResolved = true
		self.finishedPromise(.success(value))
	}
	
	public func Reject(_ error:Error)
	{
		self.hasError = error
		self.finishedPromise(.failure(error))
	}
}
