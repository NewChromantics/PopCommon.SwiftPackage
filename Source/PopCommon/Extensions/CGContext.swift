import CoreGraphics


public extension CGContext
{
	func DrawInClippedShape(clipPath:CGPath,draw:()->Void)
	{
		DrawInClippedShape(clipPath: [clipPath],draw:draw)
	}
	
	func DrawInClippedShape(clipPath:[CGPath],draw:()->Void)
	{
		//	save graphics state before clipping added
		self.saveGState()
		
		//	add clipping shapes and bake as the clipping mask
		clipPath.forEach
		{
			self.addPath($0)
		}
		self.clip()
		
		//	draw user's stuff whilst clipped
		draw()
		
		//	restore non-clipped state
		self.restoreGState()
	}
	
	func DrawAndRestoreState(draw:()->Void)
	{
		saveGState()
		draw()
		restoreGState()
	}
	
}

