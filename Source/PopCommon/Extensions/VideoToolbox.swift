import VideoToolbox
import CoreMedia

public struct VideoToolboxError : LocalizedError
{
	let result : OSStatus
	let context : String
	
	init?(_ result:OSStatus,context:String)
	{
		if result == S_OK
		{
			return nil
		}
		self.result = result
		self.context = context
	}
	
	public var errorDescription: String? 
	{
		"\(context): \(result.videoToolboxError)"
	}
	
}



public struct CoreMediaBlockBufferError : LocalizedError
{
	var result : OSStatus
	var context : String
	
	//	returns nil if not an error
	public init?(result:OSStatus,context:String)
	{
		if result == kCMBlockBufferNoErr	//	0
		{
			return nil
		}
		self.result = result
		self.context = context
	}
	
	public var errorDescription: String?
	{
		return "\(context): \(result.coreMediaBlockBufferError)"
	}
}

public extension OSStatus
{
	var coreMediaBlockBufferError : String
	{
		switch self
		{
			case kCMBlockBufferNoErr:							return "kCMBlockBufferNoErr"
			case kCMBlockBufferStructureAllocationFailedErr:	return "kCMBlockBufferStructureAllocationFailedErr"
			case kCMBlockBufferBlockAllocationFailedErr:		return "kCMBlockBufferBlockAllocationFailedErr"
			case kCMBlockBufferBadCustomBlockSourceErr:			return "kCMBlockBufferBadCustomBlockSourceErr"
			case kCMBlockBufferBadOffsetParameterErr:			return "kCMBlockBufferBadOffsetParameterErr"
			case kCMBlockBufferBadLengthParameterErr:			return "kCMBlockBufferBadLengthParameterErr"
			case kCMBlockBufferBadPointerParameterErr:			return "kCMBlockBufferBadPointerParameterErr"
			case kCMBlockBufferEmptyBBufErr:					return "kCMBlockBufferEmptyBBufErr"
			case kCMBlockBufferUnallocatedBlockErr:				return "kCMBlockBufferUnallocatedBlockErr"
			case kCMBlockBufferInsufficientSpaceErr:			return "kCMBlockBufferInsufficientSpaceErr"
			default:
				return "CoreMediaBlockBufferError(OSStatus=\(self)"
		}
	}
	
	
	var videoToolboxError : String
	{
		switch self
		{
			case kVTVideoDecoderBadDataErr:			return "kVTVideoDecoderBadDataErr"
			case kVTPropertyNotSupportedErr:		return "kVTPropertyNotSupportedErr"
			case kVTPropertyReadOnlyErr:			return "kVTPropertyReadOnlyErr"
			case kVTParameterErr:					return "kVTParameterErr"
			case kVTInvalidSessionErr:				return "kVTInvalidSessionErr"
			case kVTAllocationFailedErr:			return "kVTAllocationFailedErr"
			case kVTPixelTransferNotSupportedErr:	return "kVTPixelTransferNotSupportedErr"
			case kVTCouldNotFindVideoDecoderErr:	return "kVTCouldNotFindVideoDecoderErr"
			case kVTCouldNotCreateInstanceErr:		return "kVTCouldNotCreateInstanceErr"
			case kVTCouldNotFindVideoEncoderErr:	return 	"kVTCouldNotFindVideoEncoderErr"
			case kVTVideoDecoderBadDataErr:			return "kVTVideoDecoderBadDataErr"
			case kVTVideoDecoderUnsupportedDataFormatErr:		return 	"kVTVideoDecoderUnsupportedDataFormatErr"
			case kVTVideoDecoderMalfunctionErr:		return "kVTVideoDecoderMalfunctionErr"
			case kVTVideoEncoderMalfunctionErr:		return "kVTVideoEncoderMalfunctionErr"
			case kVTVideoDecoderNotAvailableNowErr:	return "kVTVideoDecoderNotAvailableNowErr"
			case kVTImageRotationNotSupportedErr:	return 	"kVTImageRotationNotSupportedErr"
			case kVTPixelRotationNotSupportedErr:	return "kVTPixelRotationNotSupportedErr"
			case kVTVideoEncoderNotAvailableNowErr:	return "kVTVideoEncoderNotAvailableNowErr"
			case kVTFormatDescriptionChangeNotSupportedErr:			return "kVTFormatDescriptionChangeNotSupportedErr"
			case kVTInsufficientSourceColorDataErr:	return "kVTInsufficientSourceColorDataErr"
			case kVTCouldNotCreateColorCorrectionDataErr:	return "kVTCouldNotCreateColorCorrectionDataErr"
			case kVTColorSyncTransformConvertFailedErr:		return "kVTColorSyncTransformConvertFailedErr"
			case kVTVideoDecoderAuthorizationErr:	return "kVTVideoDecoderAuthorizationErr"
			case kVTVideoEncoderAuthorizationErr:	return "kVTVideoEncoderAuthorizationErr"
			case kVTColorCorrectionPixelTransferFailedErr:	return "kVTColorCorrectionPixelTransferFailedErr"
			case kVTMultiPassStorageIdentifierMismatchErr:	return "kVTMultiPassStorageIdentifierMismatchErr"
			case kVTMultiPassStorageInvalidErr:		return "kVTMultiPassStorageInvalidErr"
			case kVTFrameSiloInvalidTimeStampErr:	return "kVTFrameSiloInvalidTimeStampErr"
			case kVTFrameSiloInvalidTimeRangeErr:	return "kVTFrameSiloInvalidTimeRangeErr"
			case kVTCouldNotFindTemporalFilterErr:	return "kVTCouldNotFindTemporalFilterErr"
			case kVTPixelTransferNotPermittedErr:	return "kVTPixelTransferNotPermittedErr"
			case kVTColorCorrectionImageRotationFailedErr:	return "kVTColorCorrectionImageRotationFailedErr"
			case kVTVideoDecoderRemovedErr:			return "kVTVideoDecoderRemovedErr"
			case kVTSessionMalfunctionErr:			return "kVTSessionMalfunctionErr"
			case kVTVideoDecoderNeedsRosettaErr:	return "kVTVideoDecoderNeedsRosettaErr"
			case kVTVideoEncoderNeedsRosettaErr:	return "kVTVideoEncoderNeedsRosettaErr"
			case kVTVideoDecoderReferenceMissingErr:	return "kVTVideoDecoderReferenceMissingErr"
			case kVTVideoDecoderCallbackMessagingErr:	return "kVTVideoDecoderCallbackMessagingErr"
			case kVTVideoDecoderUnknownErr:			return "kVTVideoDecoderUnknownErr"
			case kVTExtensionDisabledErr:			return "kVTExtensionDisabledErr"
			case kVTVideoEncoderMVHEVCVideoLayerIDsMismatchErr:	return "kVTVideoEncoderMVHEVCVideoLayerIDsMismatchErr"
			case kVTCouldNotOutputTaggedBufferGroupErr:	return "kVTCouldNotOutputTaggedBufferGroupErr"
			case kVTCouldNotFindExtensionErr:		return "kVTCouldNotFindExtensionErr"
			case kVTExtensionConflictErr:			return "kVTExtensionConflictErr"
			case kVTVideoEncoderAutoWhiteBalanceNotLockedErr:	return "kVTVideoEncoderAutoWhiteBalanceNotLockedErr"

			default:
				return "VideoToolboxError(OSStatus=\(self))"
		}
	}
}

