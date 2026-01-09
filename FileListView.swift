import SwiftUI
import QuickLook
import Foundation

/// View for displaying and managing PDF files within a folder
@available(iOS 16.0, *)
struct FileListView: View {
    let folderURL: URL
    @ObservedObject var fileManagerViewModel: FileManagerViewModel
    @State var showFilePicker = false
    @State var currentURL: URL?
    @State private var newName = ""    
    @State private var showRenameAlert = false
    @State private var showDeleteConfirm = false
    @State private var fileToRename: URL?
    @State private var indexToDelete: Int?
    
    /// Returns a filtered and sorted list of PDF files in the current folder
    private var filteredFiles: [URL] {
        fileManagerViewModel.files.filter { $0.pathExtension.localizedCaseInsensitiveContains("pdf") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
    var body: some View {
        List {
            ForEach(filteredFiles, id: \.self) { file in
                Button(file.deletingPathExtension().lastPathComponent) {
                    currentURL = file
                }
                .contextMenu {
                    Button(action: {
                        fileToRename = file
                        newName = ""
                        showRenameAlert = true
                    }, label: {
                        Label("Rename", systemImage: "pencil")
                    })
                    Button(action: {
                        showDeleteConfirm = true
                        indexToDelete = filteredFiles.firstIndex(of: file)
                    }, label: {
                        Label("Delete", systemImage: "trash")
                    })
                }
                .quickLookPreview($currentURL)
            }
            .onDelete(perform: deleteFile)
        }
        .navigationTitle(folderURL.lastPathComponent)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showFilePicker = true
                } label: {
                    Label("Add Floorplan", systemImage: "plus")
                }
                .sheet(isPresented: $showFilePicker, content: {
                    DocumentPicker(folderURL: folderURL, fileManagerViewModel: fileManagerViewModel)
                })
            }
        }
        .alert("Are you sure you want to delete this file?", isPresented: $showDeleteConfirm, actions: {
            if let index = indexToDelete {
                Button("Delete", role: .destructive, action: {
                    let fileURL = filteredFiles[index]
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                        fileManagerViewModel.files.removeAll(where: { $0 == fileURL })
                    } catch {
                        print("Error deleting file: \(error.localizedDescription)")
                    }
                    indexToDelete = nil
                })
            }
        })
        
        
        .alert("Rename File", isPresented: $showRenameAlert, actions: {
            TextField("Enter new file name", text: $newName)
            Button("Cancel", action: {
                newName = ""
            })
            Button("Rename", action: {
                guard !newName.isEmpty else { return }
                renameFile()
            })
        })
    }
    
    /// Deletes a file at the specified offset in the list
    /// - Parameter offsets: Index set containing the position of the file to delete
    func deleteFile(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let fileURL = filteredFiles[index]
        do {
            try FileManager.default.removeItem(at: fileURL)
            fileManagerViewModel.files.removeAll(where: { $0 == fileURL })
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
    
    /// Renames the currently selected file to the new name
    func renameFile() {
        guard let fileURL = fileToRename else { return }
        let newURL = fileURL.deletingLastPathComponent().appendingPathComponent(newName).appendingPathExtension(fileURL.pathExtension)
        do {
            try FileManager.default.moveItem(at: fileURL, to: newURL)
            fileManagerViewModel.files.removeAll(where: { $0 == fileURL })
            fileManagerViewModel.files.append(newURL)
        } catch {
            print("Error renaming file: \(error.localizedDescription)")
        }
        fileToRename = nil
    }
}
