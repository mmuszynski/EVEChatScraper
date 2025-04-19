//
//  LogFileController.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/10/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import Foundation
import Combine

/// Monitors a folder for changese to it, including added files and removed files
class FolderMonitor {
    
    /// The FileHandle used to describe the file to the operating system
    var folderDescriptor: CInt = -1
    
    /// The object that monitors for changes in the FileSystem
    var directoryMonitor: DispatchSourceFileSystemObject?
    let directoryMonitorQueue =  DispatchQueue(label: "directorymonitor", attributes: .concurrent)
    var directoryURL: URL
    
    init(directoryURL url: URL) {
        self.directoryURL = url
    }
    
    /// Begins the process of monitoring for new files
    /// - Parameter url: The `URL` of the folder to monitor for new files
    func beginMonitoring() {
        //open the file, readonly, and save the descriptor
        //if it fails, set to -1 to indicate that the folder is not available or something
        self.folderDescriptor = open((directoryURL as NSURL).fileSystemRepresentation, O_RDONLY)
        
        //bail out if there is no filedescriptor for the folder
        //perhaps this should throw
        guard folderDescriptor != -1 else { return }
        
        //set up the monitoring object
        self.directoryMonitor = DispatchSource.makeFileSystemObjectSource(fileDescriptor: folderDescriptor,
                                                                    eventMask: .write,
                                                                              queue: directoryMonitorQueue)
        //have process the event when it comes in
        self.directoryMonitor?.setEventHandler {
            let event = self.directoryMonitor?.data
            self.process(event)
        }
            
        //close the fd when it is canceled
        self.directoryMonitor?.setCancelHandler {
            close(self.folderDescriptor)
            self.folderDescriptor = -1
        }
            
        //start monitoring for files
        self.directoryMonitor?.activate()
    }
    
    deinit {
        self.directoryMonitor?.cancel()
    }
    
    /// Processes events from the DispatchSource when they arrive
    /// - Parameter event: The `FileSystemEvent` provided by the `DispatchSource`.
    func process(_ event: DispatchSource.FileSystemEvent?) {
        print(event)
    }
    
    
}
