/*
	Simple data-or-error type
*/

public enum DataOrError<DataType>
{
	case error(any Error)
	case data(DataType)
	
	//	DataOrError{ try GetMyData() }
	public init(get:()throws->DataType)
	{
		do
		{
			let value = try get()
			self = .data(value)
		}
		catch
		{
			self = .error(error)
		}
	}
	
	//	this now throws, so if you want optional, use try?
	public var data : DataType
	{
		get throws
		{
			switch self
			{
				case .data(let data):	return data
				case .error(let error):	throw error
			}
		}
	}
	
	public var error : (any Error)?
	{
		switch self
		{
			case .error(let error):	return error
			case .data(_):			return nil
		}
	}
}
