//
//  DocumentPicking.swift
//  vNavigator
//
//  Created by Taylor Parnell on 2/13/23.
//

import Foundation
import SwiftUI

/// UIViewControllerRepresentable wrapper for UIDocumentPickerViewController to select PDF files
@available(iOS 16.0, *)
struct DocumentPicker: UIViewControllerRepresentable {
    
    var folderURL: URL
    
    @ObservedObject var fileManagerViewModel: FileManagerViewModel
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker =
        UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = true
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            for pickedURL in urls {
                do {
                    // Add the picked file to the folder's directory
                    let fileURL = parent.folderURL.appendingPathComponent(pickedURL.lastPathComponent)
                    try FileManager.default.copyItem(at: pickedURL, to: fileURL)
                    // Update the list of files in the view model
                    parent.fileManagerViewModel.loadFiles()
                } catch {
                    print("Error copying file: \(error.localizedDescription)")
                }
            }
        }
    }
}
