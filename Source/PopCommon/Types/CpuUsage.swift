import Foundation
import Darwin
#if os(macOS)
import IOKit
#endif

// Measures whole-machine CPU usage across all cores.
// CPU usage is measured in ticks, categorised as busy or idle (total-busy = idle).
// On every read we can tell how many ticks were busy or idle for usage.
public class GlobalCpuUsage
{
	private var lastBusyTicks: UInt64 = 0
	private var lastTotalTicks: UInt64 = 0
	private var lastValue = 0
	public private(set) var cpuCount: Int = 0
	
	private static let host = mach_host_self()
	
	public init() {
		// Initial read of values since bootup so first read is 0
		if let initial = Self.systemTicks() {
			lastBusyTicks = initial.busyTicks
			lastTotalTicks = initial.totalTicks
			cpuCount = initial.cpuCount
		}
	}
	
	// Returns whole-machine CPU usage, 0...100%.
	public func read() -> (percent: Int, cpuCount: Int) {
		guard let current = Self.systemTicks() else { return (lastValue, cpuCount) }
		
		let dBusy = current.busyTicks &- lastBusyTicks
		let dTotal = current.totalTicks &- lastTotalTicks
		
		lastBusyTicks = current.busyTicks
		lastTotalTicks = current.totalTicks
		cpuCount = current.cpuCount
		
		if dTotal > 0 {
			lastValue = Int((Double(dBusy) / Double(dTotal) * 100).rounded())
		}
		return (lastValue, cpuCount)
	}
	
	// Returns busy and total ticks summed over all cores since boot.
	private static func systemTicks() -> (busyTicks: UInt64, totalTicks: UInt64, cpuCount: Int)? 
	{
		var cpuCount: natural_t = 0
		var info: processor_info_array_t?
		var infoCount: mach_msg_type_number_t = 0
		
		//	cpu count here is number of proccesses for the kernel, so with hyperthreading its 2x core count
		guard host_processor_info(host, PROCESSOR_CPU_LOAD_INFO,
								  &cpuCount, &info, &infoCount) == KERN_SUCCESS,
			  let info else 
		{
			return nil
		}
		
		defer 
		{
			vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), vm_size_t(Int(infoCount) * MemoryLayout<integer_t>.stride))
		}
		
		var busy: UInt64 = 0
		var total: UInt64 = 0
		for core in 0..<Int(cpuCount) 
		{
			let base = core * Int(CPU_STATE_MAX)
			let tick = { (s: Int32) in
				UInt64(UInt32(bitPattern: info[base + Int(s)]))
			}
			let b = tick(CPU_STATE_USER) + tick(CPU_STATE_SYSTEM) + tick(CPU_STATE_NICE)
			busy += b
			total += b + tick(CPU_STATE_IDLE)
		}
		return (busyTicks: busy, totalTicks: total, cpuCount: Int(cpuCount))
	}
}



// Measures this process's CPU usage.
// CPU usage is measured in nanoseconds of CPU time vs wall-clock time.
// 100% = one full core (can exceed 100% with multiple threads).
public class ProcessCpuUsage {
	
	private var lastCpuTime: UInt64 = 0
	private var lastWallTime: UInt64 = 0
	private var lastValue = 0
	
	public init() {
		// Initial read of values so first read is 0
		(lastCpuTime, lastWallTime) = Self.processTimes()
	}
	
	// Returns this process's CPU usage, where 100 = one full core (can exceed 100 with multiple threads).
	public func read() -> (percent: Int, coreCount: Int) 
	{
		let (cpu, wall) = Self.processTimes()
		let dCPU = cpu - lastCpuTime
		let dWall = wall - lastWallTime
		lastCpuTime = cpu
		lastWallTime = wall
		let cores = ProcessInfo.processInfo.activeProcessorCount
		
		if dWall > 0 {
			let norm = Double(dCPU) / Double(dWall)
			lastValue = Int((norm * 100.0).rounded())
		}
		return (lastValue, cores)
	}
	
	/// Returns (CPU time used by this process, wall-clock time), both in nanoseconds.
	private static func processTimes() -> (cpuNs: UInt64, wallNs: UInt64) {
		var ru = rusage()
		getrusage(RUSAGE_SELF, &ru)
		
		func ns(_ t: timeval) -> UInt64 {
			UInt64(t.tv_sec) * 1_000_000_000 + UInt64(t.tv_usec) * 1_000
		}
		
		let timeInSystemCallsNanos = ns(ru.ru_stime)
		let timeInUserCallsNanos = ns(ru.ru_utime)
		
		// Use monotonic time instead of uptime for accurate wall-clock measurement
		let totalTimeNanos = clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)
		
		return (timeInUserCallsNanos + timeInSystemCallsNanos, totalTimeNanos)
	}
}




// Reads system-wide (all processes) GPU utilization.
//
// - macOS: reads the undocumented `"Device Utilization %"` value from each
//   `IOAccelerator`'s `PerformanceStatistics` in the IORegistry.
// - iOS / iPadOS / visionOS / tvOS / watchOS: there is no public API for
//   system-wide GPU usage, so readings are empty.
public final class GlobalGpuUsage 
{
	// Whether system-wide GPU readings are available on this platform.
	static var isSupported: Bool 
	{
#if os(macOS)
		return true
#else
		return false
#endif
	}
	
	public init() 
	{
	}
	

	// Utilization (0–100) for each GPU found, one entry per GPU.
	// Empty if unavailable.
	public func read() -> [Int] 
	{
#if os(macOS)
		var results: [Int] = []
		var iterator = io_iterator_t()
		
		// MACH_PORT_NULL is the default main port (same as kIOMainPortDefault,
		// but avoids the macOS 12 availability check / deprecated name).
		guard IOServiceGetMatchingServices(mach_port_t(MACH_PORT_NULL),
										   IOServiceMatching("IOAccelerator"),
										   &iterator) == KERN_SUCCESS else {
			return results
		}
		defer 
		{
			IOObjectRelease(iterator) 
		}
		
		var entry = IOIteratorNext(iterator)
		while entry != 0 
		{
			var props: Unmanaged<CFMutableDictionary>?
			if IORegistryEntryCreateCFProperties(entry, &props, kCFAllocatorDefault, 0) == KERN_SUCCESS
			{
				if let dict = props?.takeRetainedValue() as? [String: Any],
				   let stats = dict["PerformanceStatistics"] as? [String: Any],
				   let util = stats["Device Utilization %"] as? NSNumber 
				{
					results.append(util.intValue)
				}
			}
			IOObjectRelease(entry)
			entry = IOIteratorNext(iterator)
		}
		return results
#else
		return []
#endif
	}
	
}
