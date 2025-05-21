import CoreVideo


#if !canImport(ARKit)
public typealias simd_float4x4 = float4x4
public typealias ARSession = ARSessionPolyfill
public typealias ARWorldTrackingConfiguration = ARWorldTrackingConfigurationPolyfill
public typealias ARCamera = ARCameraPolyfill
public typealias ARFrame = ARFramePolyfill
public typealias ARSessionDelegate = ARSessionDelegatePolyfill
#endif

public struct float4x4
{
	public init()
	{
	}
	
	public subscript(_ index: Float) -> Float 
	{
		get {
			return 0
		}
		set(newValue)
		{
		}
	}
	
	public subscript(_ column: Float,_ row: Float) -> Float
	{
		get {
			return 0
		}
		set(newValue)
		{
		}
	}
	
	public var transpose : float4x4
	{
		return float4x4()
	}
	
	public var inverse : float4x4
	{
		return float4x4()
	}
	
}


public struct ARSessionPolyfill
{
	public var currentFrame : ARFramePolyfill? = nil
	public var delegate : ARSessionDelegatePolyfill? = nil
	
	public func run(_ config:ARWorldTrackingConfigurationPolyfill)
	{
		Task
		{
			while ( !Task.isCancelled )
			{
				try await Task.sleep(nanoseconds: 10000000)
				let frame = ARFramePolyfill()
				delegate?.session(self, didUpdate: frame)
			}
		}
	}
	
	public init()
	{
	}
}

public struct ARCameraPolyfill
{
	public var transform = float4x4()
	public var projectionMatrix = float4x4()
	
	public init(transform: float4x4 = float4x4(), projectionMatrix: float4x4 = float4x4()) {
		self.transform = transform
		self.projectionMatrix = projectionMatrix
	}
}

public struct ARWorldTrackingConfigurationPolyfill
{
	public init()
	{
	}
}

public struct ARFramePolyfill
{
	public var timestamp = 123
	public var capturedDepthDataTimestamp = 123
	public var camera = ARCameraPolyfill()
	public var capturedImage : CVPixelBuffer
	
	public init()
	{
		self.capturedImage = try! Create1x1CVPixelBuffer(colour: CGColor(red: 1, green: 0, blue: 0, alpha: 1) )
	}
}

/*@objc */public protocol ARSessionDelegatePolyfill
{
	/*@objc optional */func session(_ session: ARSessionPolyfill, didUpdate frame: ARFramePolyfill)

}


