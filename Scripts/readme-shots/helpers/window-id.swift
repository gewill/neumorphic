import AppKit
import CoreGraphics
import Foundation

// Find only the normal window owned by the process launched for this capture.
guard CommandLine.arguments.count == 2, let pid = Int(CommandLine.arguments[1]) else {
    exit(2)
}
NSRunningApplication(processIdentifier: pid_t(pid))?.activate(options: [.activateIgnoringOtherApps])
Thread.sleep(forTimeInterval: 0.5)
let windows =
    CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]
    ?? []
for window in windows {
    if window[kCGWindowOwnerPID as String] as? Int == pid,
        window[kCGWindowLayer as String] as? Int == 0,
        let number = window[kCGWindowNumber as String] as? Int
    {
        print(number)
        exit(0)
    }
}
exit(1)
