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
	
	func DrawFlipped(_ image: CGImage, in rect: CGRect) 
	{
		DrawAndRestoreState
		{
			self.translateBy(x: 0, y: rect.origin.y + rect.height)
			self.scaleBy(x: 1.0, y: -1.0)
			self.draw(image, in: CGRect(origin: CGPoint(x: rect.origin.x, y: 0), size: rect.size))
		}
	}
	
	func DrawAndRestoreState(draw:()->Void)
	{
		saveGState()
		draw()
		restoreGState()
	}
	
}

