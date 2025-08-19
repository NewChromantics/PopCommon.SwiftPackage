import SwiftUI
import Combine



@available(macOS 14, *)
struct TaskWithProgressView : View
{
	@ObservedObject var taskWithProgress : DetachedTaskWithProgress

	var body: some View 
	{
		VStack
		{
			let step = taskWithProgress.lastStep ?? "Initialising..."
			Text("Progress... \(step)")
			
			if let error = taskWithProgress.error
			{
				Text("Error: \(error.localizedDescription)")
					.foregroundStyle(.white)
					.background(.red)
					.dismissableStyle()
			}
			else if taskWithProgress.errorDismissed == nil
			{
				Button(action:taskWithProgress.OnUserCancelled)
				{
					Text("Cancel")
				}
				.buttonStyle(PokerButton())
			}
			
			if taskWithProgress.errorDismissed != nil
			{
				Button(action:taskWithProgress.OnErrorDismissed)
				{
					Text("Ok")
				}
				.buttonStyle(PokerButton())
			}
		}
	}
}



//	doesn't have to be detatched, but so far, always using it that way
@available(macOS 14, *)
public class DetachedTaskWithProgress : ObservableObject
{
	var showOkayOnSuccess = false
	//var theTask : (_ onStep:String)throws->Void
	//var progressiveTask : ( _ onStep:(String)throws->Void )async throws->Void
	@Published var taskWrapper : Task<Void,Error>!
	@Published var lastStep : String?
	@Published var error : Error?	//	can we get this from taskWrapper?

	@Published var errorDismissed : Future<Void,Never>.Promise?
	
	var onFinished : ()->Void
	
	public init(onFinished:@escaping()->Void,_ closure:@escaping( _ onStep:@escaping(String)throws->Void )async throws->Void)
	{
		self.onFinished = onFinished
		
		//self.progressiveTask = closure
		self.taskWrapper = Task
		{
			do
			{
				print("Starting closure")
				let closureTask = Task.detached(priority: .high)
				{
					try await closure(self.OnStep)
				}
				try await closureTask.value
				print("Closure Done")
				
				if showOkayOnSuccess
				{
					let dismissFuture = Future()
					{
						promise in
						DispatchQueue.main.async
						{
							self.errorDismissed = promise
						}
					}
					await dismissFuture.value
				}
			}
			catch
			{
				self.error = error
				let dismissFuture = Future()
				{
					promise in
					DispatchQueue.main.async
					{
						self.errorDismissed = promise
					}
				}
				await dismissFuture.value
			}
			onFinished()
		}
	}
	
	private func OnStep(step:String) throws
	{
		print("OnStep \(step)")
		DispatchQueue.main.async
		{
			self.lastStep = step
		}

		//	throw if cancelled by user
		if taskWrapper.isCancelled
		{
			print("task is cancelled after \(step)")
			throw RuntimeError("Task is cancelled")
		}
	}
	
	func OnUserCancelled()
	{
		print("User cancelled")
		self.taskWrapper.cancel()
	}
	
	func OnErrorDismissed()
	{
		self.errorDismissed?(Result.success(Void()))
	}
	
	@ViewBuilder public func View() -> some View
	{
		TaskWithProgressView(taskWithProgress: self)
	}
}

@available(macOS 13, *)
internal func LongPreviewTask(_ OnStep:(_ step:String)throws->Void) async throws
{
	try OnStep("one...")
	print("one")
	try await Task.sleep(for:.seconds(1))
	
	try OnStep("two...")
	print("two")
	try await Task.sleep(for:.seconds(1))
	
	try OnStep("Done")
	print("Done")
}

@available(macOS 14, *)
#Preview
{
	@Previewable @State var runningTask : DetachedTaskWithProgress?
	
	let StartTask = 
	{
		runningTask = DetachedTaskWithProgress(onFinished:{runningTask=nil})
		{
			onStep in
			try await LongPreviewTask(onStep)
		}
	}
	
	Button(action:{StartTask()})
	{
		Text("Start")
	}
	.padding(20)
	.frame(width:200,height:200)
	.overlay
	{
		if let runningTask
		{
			runningTask.View()
		}
	}
}
