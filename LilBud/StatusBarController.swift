import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    
    private enum IconType {
        case day, night, transition, clicked
    }
    
    private var currentIcon: IconType = .night  // Assume it's daytime initially
    
    init(_ popover: NSPopover) {
        self.popover = popover
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28.0)
        
        updateStatusBarIcon()
        
        // Set up a timer to update the status bar icon every half minute
        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(updateStatusBarIcon), userInfo: nil, repeats: true)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            statusBarButton.action = #selector(handleStatusBarClick(sender:))
            statusBarButton.target = self
        }
    }
    
    @objc func handleStatusBarClick(sender: AnyObject) {
        currentIcon = .clicked
        
        updateStatusBarIcon()
        
        // Toggle the popover
        if popover.isShown {
            
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    @objc func togglePopover(sender: AnyObject) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
        
        // Change the status bar icon when the popover is shown or hidden
        updateStatusBarIcon()
    }
    
    func showPopover(_ sender: AnyObject) {
        if let statusBarButton = statusItem.button {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
        }
    }
    
    func hidePopover(_ sender: AnyObject) {
        currentIcon = .night
        updateStatusBarIcon()
        popover.performClose(sender)
    }
    
    @objc func updateStatusBarIcon() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        if(currentIcon != .clicked) {
            if(currentHour >= 6 && currentHour < 18) {
                currentIcon = .day
            }
            else if(currentHour >= 19 || currentHour < 5) {
                currentIcon = .night
            }
            else {
                currentIcon = .transition
            }
        }
        var iconImage: NSImage?
        
        switch currentIcon {
        case .day:
            iconImage = NSImage(named: NSImage.Name("Day"))
        case .night:
            iconImage = NSImage(named: NSImage.Name("Night"))
        case .transition:
            // Check if it's one hour before night starts or one hour after day starts
            if (currentHour >= 5 && currentHour < 6) || (currentHour >= 18 && currentHour < 19) {
                iconImage = NSImage(named: NSImage.Name("Transition"))
            } else {
                // Fall back to day icon if not in the transition period
                iconImage = NSImage(named: NSImage.Name("Day"))
            }
        case .clicked:
            iconImage = NSImage(named: NSImage.Name("Clicked"))
        }
        
        statusItem.button?.image = iconImage
    }
}
