import Cocoa
import FinderSync

class FinderContextualUtilities: FIFinderSync {
    
    var myFolderURL = URL(fileURLWithPath: "/")
    
    override init() {
        super.init()
        
        NSLog("FinderContextualUtilitiesFinderSync() launched from %@", Bundle.main.bundlePath as NSString)
        
        // Set up the directory we are syncing
        FIFinderSyncController.default().directoryURLs = [self.myFolderURL]
        
        // Set up images for our badge identifiers
        FIFinderSyncController.default().setBadgeImage(NSImage(named: NSImage.folderSmartIcon)!, label: "Extract" , forBadgeIdentifier: "extract")
    }
    
    // MARK: - Primary Finder Sync protocol methods
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        
        // Get selected items
        guard let items = FIFinderSyncController.default().selectedItemURLs(), !items.isEmpty else {
            return menu
        }
        
        // Check if we have multiple items selected
        let multipleItems = items.count > 1
        
        // Add Extract Contents option for folders
        if items.allSatisfy({ $0.hasDirectoryPath }) {
            let flags = NSEvent.modifierFlags
            let optionKeyPressed = flags.contains(.option)
            
            let title = optionKeyPressed ? "Extract Contents (Keep Folder)" : "Extract Contents"
            let item = NSMenuItem(title: title, action: #selector(extractAction(_:)), keyEquivalent: "")
            item.keyEquivalentModifierMask = optionKeyPressed ? .option : []
            item.representedObject = optionKeyPressed // Store whether to keep the folder
            menu.addItem(item)
            
            if multipleItems {
                menu.addItem(.separator())
            }
        }
        
        // Add Move/Copy to New Folder option for multiple selections
        if multipleItems {
            let flags = NSEvent.modifierFlags
            let optionKeyPressed = flags.contains(.option)
            
            let title = optionKeyPressed ? "Copy to New Folder" : "Move to New Folder"
            let newFolderItem = NSMenuItem(title: title, action: #selector(moveToNewFolderAction(_:)), keyEquivalent: "n")
            newFolderItem.keyEquivalentModifierMask = optionKeyPressed ? [.command, .shift, .option] : [.command, .shift]
            newFolderItem.representedObject = optionKeyPressed // Store whether to copy instead of move
            menu.addItem(newFolderItem)
        }
        
        return menu
    }
    
    @objc func extractAction(_ sender: NSMenuItem?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs(), !items.isEmpty else { return }
        let keepFolder = sender?.representedObject as? Bool ?? false
        
        for item in items {
            extractContents(from: item, keepFolder: keepFolder)
        }
    }
    
    // MARK: - Move to New Folder
    
    @objc private func moveToNewFolderAction(_ sender: Any?) {
        guard let menuItem = sender as? NSMenuItem,
              let items = FIFinderSyncController.default().selectedItemURLs(),
              !items.isEmpty,
              let firstURL = items.first else {
            return
        }
        
        let shouldCopy = (menuItem.representedObject as? Bool) ?? false
        let parentURL = firstURL.deletingLastPathComponent()
        let newFolderName = self.availableFolderName(startingWith: "New Folder", in: parentURL)
        let newFolderURL = parentURL.appendingPathComponent(newFolderName)
        
        do {
            // Create the new folder
            try FileManager.default.createDirectory(at: newFolderURL, withIntermediateDirectories: false)
            
            // Move or copy all items to the new folder
            for itemURL in items {
                let destination = newFolderURL.appendingPathComponent(itemURL.lastPathComponent)
                if shouldCopy {
                    try? FileManager.default.copyItem(at: itemURL, to: destination)
                } else {
                    try? FileManager.default.moveItem(at: itemURL, to: destination)
                }
            }
            
            // Reveal the new folder in Finder
            NSWorkspace.shared.selectFile(newFolderURL.path, inFileViewerRootedAtPath: "")
            
            // Rename the folder (this will put it in edit mode)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let script = """
                tell application "Finder"
                    set theSelection to POSIX file "\(newFolderURL.path)" as alias
                    select theSelection
                    activate
                    delay 0.5
                    tell application "System Events"
                        keystroke return
                        delay 0.1
                        keystroke "a" using command down
                    end tell
                end tell
                """
                
                var error: NSDictionary?
                if let scriptObject = NSAppleScript(source: script) {
                    scriptObject.executeAndReturnError(&error)
                    if let error = error {
                        NSLog("Error executing AppleScript: \(error)")
                    }
                }
            }
            
        } catch {
            NSLog("Failed to create folder or move items: \(error)")
            NSSound(named: .funk)?.play()
        }
    }
    
    private func availableFolderName(startingWith baseName: String, in directory: URL) -> String {
        let fileManager = FileManager.default
        var name = baseName
        var counter = 1
        
        while fileManager.fileExists(atPath: directory.appendingPathComponent(name).path) {
            // Check if the name already ends with a number in parentheses
            let pattern = #"\(\d+\)$"#
            if let range = name.range(of: pattern, options: .regularExpression) {
                // Extract the number and increment it
                let numberString = name[range].trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                if let number = Int(numberString) {
                    counter = number + 1
                    name = String(name[..<range.lowerBound])
                }
            }
            
            // Remove any existing number and space at the end
            name = name.trimmingCharacters(in: .whitespaces)
            
            // Add the new number
            name = "\(name) \(counter)"
            counter += 1
        }
        
        return name
    }
    
    // MARK: - Extract Contents
    
    private func extractContents(from url: URL, keepFolder: Bool) {
        let fileManager = FileManager.default
        let parentURL = url.deletingLastPathComponent()
        var encounteredError: Error? = nil
        var movedItems = [URL]()
        
        do {
            // Get all items in the folder
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            
            // Move each item to the parent directory
            for item in contents {
                let destination = parentURL.appendingPathComponent(item.lastPathComponent)
                
                do {
                    // Remove destination if it exists
                    if fileManager.fileExists(atPath: destination.path) {
                        try fileManager.removeItem(at: destination)
                    }
                    
                    try fileManager.moveItem(at: item, to: destination)
                    movedItems.append(destination)
                } catch {
                    encounteredError = error
                    NSLog("Failed to move item \(item.lastPathComponent): \(error)")
                    // Continue with other items even if one fails
                }
            }
            
            // Select the moved items in Finder
            if !movedItems.isEmpty {
                DispatchQueue.main.async {
                    let urls = movedItems as [Any]
                    NSWorkspace.shared.activateFileViewerSelecting(urls)
                }
            }
            
            // Only remove the folder if there was no error and we're not keeping it
            if encounteredError == nil && !keepFolder {
                do {
                    try fileManager.removeItem(at: url)
                } catch {
                    encounteredError = error
                    NSLog("Failed to remove folder: \(error)")
                }
            }
            
            if let error = encounteredError {
                throw error
            }
            
        } catch {
            NSLog("Failed to extract contents: \(error)")
            NSSound(named: .funk)?.play()
        }
    }
}
