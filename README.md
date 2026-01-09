# vNavigator

A SwiftUI iOS application for organizing and viewing PDF map files, designed to help users manage building floor plans and navigate through them efficiently.

## Features

- 📁 **Folder Management**: Create, rename, and delete building folders
- 📄 **PDF File Management**: Import, view, rename, and delete PDF files
- 📱 **iOS 16+ Support**: Built with modern SwiftUI and iOS 16 features
- 🔍 **Quick Look Integration**: Preview PDF files directly within the app
- 📥 **Import Support**: Import folders and PDF files from other locations

## App Store

Link to the app on the App Store: [vNavigator](https://apps.apple.com/us/app/vnavigator/id6443606942)

## Requirements

- iOS 16.0 or later
- Xcode 14.0 or later (for development)
- Swift 5.7 or later

## Installation

1. Download from the [App Store](https://apps.apple.com/us/app/vnavigator/id6443606942)
2. Or clone this repository and build with Xcode

## Usage

### Managing Buildings (Folders)
- Tap the **+** button to create a new building folder
- Use the **import** button to import an existing folder
- Long press or swipe on a building to rename or delete it

### Managing Floor Plans (PDF Files)
- Navigate into a building folder
- Tap the **+** button to add PDF files
- Tap on any PDF to view it in Quick Look
- Long press or swipe on a file to rename or delete it

## Project Structure

- `MyApp.swift` - Main app entry point
- `FolderListView.swift` - Main view for listing building folders
- `FileListView.swift` - View for displaying PDF files within a folder
- `FileManager.swift` - View model for managing file operations
- `DocumentPicking.swift` - Document picker for PDF files
- `FolderPicking.swift` - Folder picker for importing folders

## License

Copyright © 2023. All rights reserved.
