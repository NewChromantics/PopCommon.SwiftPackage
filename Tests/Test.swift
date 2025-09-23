import Testing
import PopCommon


struct Rect_Tests
{
	@Test func TestInside() async throws 
	{
		let rect = Rect(left: 25, top: 25, width: 100, height: 100)
	
		let outside = (-100,-100)
		let inside = (30,30)
		#expect( rect.GetClipRegion(x: inside.0, y: inside.1).isInside )
		#expect( !rect.GetClipRegion(x: inside.0, y: inside.1).isOutside )
		#expect( rect.GetClipRegion(x: outside.0, y: outside.1).isOutside )
		#expect( !rect.GetClipRegion(x: outside.0, y: outside.1).isInside )
		
	}
	
	@Test func TopEdgeClip() async throws 
	{
		let rect = Rect(left: 25, top: 25, width: 100, height: 100)
		
		let start = SIMD2<Int>( rect.left, rect.top )
		let end = SIMD2<Int>( rect.right, rect.top )
		let clippedStartEnd = rect.ClipLine(p1: start, p2: end)
		#expect( clippedStartEnd != nil )
		if let clippedStartEnd
		{
			let clippedStart = clippedStartEnd.0
			let clippedEnd = clippedStartEnd.1
			#expect( clippedStart == start )
			#expect( clippedEnd == end )
		}
	}

	//	test a line is culled if outside with different regions
	@Test func OutsideBottomRightClip() async throws 
	{
		let rect = Rect(left: 25, top: 25, width: 100, height: 100)
		
		let start = SIMD2<Int>( rect.right+10, rect.top-10 )
		let end = SIMD2<Int>( rect.right+10, rect.bottom+10 )
		let clippedStartEnd = rect.ClipLine(p1: start, p2: end)
		#expect( clippedStartEnd == nil )
	}
}
