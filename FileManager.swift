import Foundation
import SwiftUI


/// View model for managing files within a folder
@available(iOS 16.0, *)
class FileManagerViewModel: ObservableObject {    
    var folderURL: URL
    
    init(folderURL: URL) {
        self.folderURL = folderURL
        // Load the initial list of files in the folder
        loadFiles()
    }
    
    @Published var files: [URL] = []
    
    /// Loads all files from the folder URL
    func loadFiles() {
        do {
            self.files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [])
        } catch {
            print("Error loading files: \(error.localizedDescription)")
        }
    }
}



