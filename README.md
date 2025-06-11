# FinderKeeper

Enhance Finder's right-click menu with actions that should have been there from the start.

## Features

### Extracting Folder Contents
1. Right-click on any folder in Finder
2. Select "Extract Contents" from the context menu, or hold Option (⌥) and select "Extract Contents (Keep Folder)"
3. The folder's contents will be moved up one level
4. The empty folder will be deleted unless you chose to keep it

### Moving or Copying Multiple Items to a New Folder
1. Select multiple items in Finder
2. Right-click and choose one of the following:
   - "Move to New Folder" (or press ⌘⇧N) to move items
   - Hold Option (⌥) and choose "Copy to New Folder" (or press ⌥⌘⇧N) to copy items
3. A new folder will be created with a unique name
4. The folder name will be selected for immediate renaming

### General:
- Plays an error sound if any operation fails
- Universal binary - works natively on both Intel and Apple Silicon Macs

## Installation (For Users)

### Using Pre-built Application

1. Download the latest `FinderKeeper.app.zip` from the [Releases](https://github.com/liperama-dev/finder-contextual-utilities/releases) page
2. Extract the zip file
3. Move `FinderKeeper.app` to your `/Applications` folder
4. Run the app once to install the extension
5. Enable the extension in System Preferences > Extensions > Finder Extensions
6. Grant Full Disk Access in System Preferences > Security & Privacy > Privacy > Full Disk Access

## Building from Source (For Developers)

### Prerequisites

- Xcode 12.0 or later
- macOS 10.10 or later

### Building

1. Clone the repository:
   ```bash
   git clone https://github.com/liperama-dev/finder-contextual-utilities.git
   cd finder-contextual-utilities
   ```

2. Open the project in Xcode:
   ```bash
   open "finder-contextual-utilities/FinderKeeper.xcodeproj"
   ```

3. Build and run the project (⌘R) to install the extension

### Creating a Distribution Package

To create a distributable .app bundle:

```bash
./build_distribution.sh
```

This will create a `dist` directory containing:
- `FinderKeeper.app` - The application bundle
- `FinderKeeper.zip` - A zip file suitable for distribution

## Requirements

- macOS 10.10 or later
- Xcode 12.0 or later (for building from source)

## Troubleshooting

- If the "Extract Contents" option doesn't appear in the context menu:
  - Make sure the extension is enabled in System Preferences > Extensions > Finder Extensions
  - Try restarting Finder: `killall Finder` (or ⌥ + right-click the Finder icon in the Dock and select Relaunch)
  - Ensure the app has Full Disk Access in System Preferences > Security & Privacy > Privacy > Full Disk Access

## Usage Tips

- Use ⌘⇧N as a keyboard shortcut for "Move to New Folder"
- Use ⌥⌘⇧N as a keyboard shortcut for "Copy to New Folder"
- The new folder name follows macOS conventions (e.g., "New Folder", "New Folder 2", etc.)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)
