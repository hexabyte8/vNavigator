
import Foundation
import SwiftUI

/// Main view for displaying and managing building folders
@available(iOS 16.0, *)
struct FolderListView: View {
    @State var folders: [Folder] = []
    @State private var folderName = ""
    @State private var newName = ""
    @State private var isPresentingAddFolderAlert = false
    @State private var isPresentingRenameFolderAlert = false
    @State private var isPresentingDeleteWarning = false
    @State var showFolderPicker = false
    @State var indexToDelete: Int?
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(folders) { folder in
                        NavigationLink(
                            destination: FileListView(
                                folderURL: folder.url,
                                fileManagerViewModel: FileManagerViewModel(folderURL: folder.url)
                            )
                        ) {
                            Text(folder.name)
                                .contextMenu {
                                    Button(action: {
                                        folderName = folder.name
                                        isPresentingRenameFolderAlert = true
                                    }) {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    
                                    Button(action: {
                                        indexToDelete = folders.firstIndex(of: folder)
                                        isPresentingDeleteWarning = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .onDelete(perform: deleteFolder)
                }
            }
            .navigationTitle("Buildings")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showFolderPicker = true
                    }
                label: {
                    Label("Import Building", systemImage: "square.and.arrow.down")
                }
                .sheet(isPresented: $showFolderPicker, content: {
                    FolderPicker(fileManagerViewModel: self)
                })
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingAddFolderAlert = true
                        folderName = ""
                    } label: {
                        Label("Add Building", systemImage: "plus")
                    }
                }
            }
        }
        .onAppear {
            loadFolders()
        }
        .alert("Are you sure you want to delete this building?", isPresented: $isPresentingDeleteWarning, actions: {
            Button("Delete", role: .destructive, action: {
                guard let index = indexToDelete else { return }
                try? FileManager.default.removeItem(at: folders[index].url)
                folders.remove(at: index)
                indexToDelete = nil
            })
        })
        .alert("Rename Building", isPresented: $isPresentingRenameFolderAlert, actions: {
            TextField("Rename Building", text: $newName)
            Button("Cancel", action: {
                newName = ""
            })
            Button("Rename Building", action: {
                guard let index = folders.firstIndex(where: { $0.name == folderName }) else { return }
                renameFolder(at: index)
                newName = ""
            })
        })
        
        .alert("Add Building", isPresented: $isPresentingAddFolderAlert, actions: {
            TextField("Building Name", text: $folderName)
            Button("Cancel", action:  {
                folderName = ""
            })
            Button("Add Building", action: {
                saveFolder()
                folderName = ""
            })
        })
    }
    
    /// Loads all folders from the documents directory
    func loadFolders() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folderURLs = try FileManager.default.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
            )
            self.folders = folderURLs.compactMap { url in
                try? Folder(name: url.lastPathComponent, url: url)
            }.sorted(by: { $0.name < $1.name})
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Creates a new folder with the specified name
    func saveFolder() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folderURL = documentsURL.appendingPathComponent(folderName)
            let folder = try Folder(name: folderName, url: folderURL)
            folders.append(folder)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Deletes a folder at the specified offset in the list
    /// - Parameter offsets: Index set containing the position of the folder to delete
    func deleteFolder(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let folderURL = folders[index]
        do {
            try FileManager.default.removeItem(at: folderURL.url)
            folders.remove(atOffsets: offsets)
        } catch {
            print("Error deleting folder: \(error.localizedDescription)")
        }
    }
    
    /// Renames a folder at the specified index
    /// - Parameter index: The index of the folder to rename
    func renameFolder(at index: Int) {
        let folder = folders[index]
        let newURL = folder.url.deletingLastPathComponent().appendingPathComponent(newName)
        do {
            try FileManager.default.moveItem(at: folder.url, to: newURL)
            folders[index].name = newName
            loadFolders()
        } catch {
            print("Error renaming folder: \(error.localizedDescription)")
        }
    }
}

/// Represents a folder in the file system
struct Folder: Identifiable, Equatable {
    let id = UUID()
    var name: String
    let url: URL
    
    init(name: String, url: URL) throws {
        self.name = name
        self.url = url
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
