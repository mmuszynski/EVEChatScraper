//
//  ActiveChatOutlineViewController.swift
//  EVEChatScraper
//
//  Created by Mike Muszynski on 4/18/25.
//  Copyright © 2025 Mike Muszynski. All rights reserved.
//

import Cocoa
import Combine

extension Notification.Name {
    static let refreshOutlineView = Notification.Name("com.mmuszynski.EVEChatScraper.refreshOutlineView")
}

class ActiveChatOutlineViewController: NSViewController {
    @MainActor var controller: LogFileController = LogFileController.shared
    @IBOutlet weak var logView: NSTextView!
    
    var outlineView: NSOutlineView {
        self.view as! NSOutlineView
    }
    
    var cancellable: AnyCancellable?
    var refreshTableCancellable: AnyCancellable?
    
    override func awakeFromNib() {
        Task {
            await MainActor.run {
                do {
                    try controller.loadFiles()
                    outlineView.reloadData()
                } catch {
                    fatalError("\(error)")
                }
                
                cancellable = NotificationCenter.default
                    .publisher(for: .logUpdated)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] notification in
                        self?.receive(notification)
                    }
            }
        }
    }
    
    func playSound() {
        guard let soundName = UserDefaults.standard.string(forKey: "alertSound") else { return }
        NSSound(named: soundName)?.play()
    }
    
    func receive(_ notification: Notification) {
        playSound()
        guard let log = notification.object as? LogFileMonitor else { return }
        
        //get selection
        var selection: LogFile? = nil
        let row = self.outlineView.selectedRow
        if row != -1 {
            selection = controller.logFiles[row]
        }
        
        self.outlineView.reloadData()
        
        if let selection, let newSelectedRow = controller.logFiles.firstIndex(of: selection) {
            self.outlineView.selectRowIndexes(IndexSet(integer: newSelectedRow), byExtendingSelection: false)
        }
    }
}

extension ActiveChatOutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return controller.chatChannels.count
        }
        
        return (item as? ChatChannel)?.files.count ?? 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return Array(controller.chatChannels)[index]
        } else {
            return controller.chatChannels.first { $0 == (item as? ChatChannel) }!.files[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let log = item as? LogFileMonitor {
            return log
        }
        
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "DataCell")
        let cell = outlineView.makeView(withIdentifier: identifier, owner: self) as! LogFileCellView
        
        if let log = item as? LogFile {
            cell.logNameField?.stringValue = log.name
            cell.lastLineField.stringValue = log.lastLine
            cell.lastLineField?.maximumNumberOfLines = 3
            cell.unreadIndicator.isHidden = log.hasUpdates
        } else if let channel = item as? ChatChannel {
            cell.logNameField.stringValue = channel.name
            cell.lastLineField.stringValue = "\(channel.files.count) files"
        }
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is ChatChannel
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selection = outlineView.selectedRow
        if let log = outlineView.item(atRow: selection) as? LogFileMonitor {
            loadDetailView(for: log)
            try? log.setRead()
        }
        outlineView.reloadData(forRowIndexes: IndexSet(integer: selection), columnIndexes: IndexSet(integer: 0))
    }
    
    func loadDetailView(for log: LogFileMonitor) {
        let logText = log.lines.joined(separator: "\n")
        logView.string = logText
        reloadOutlineViewRow(for: log)
        logView.scrollToEndOfDocument(self)
    }
    
    func reloadOutlineViewRow(for log: LogFileMonitor) {
        let rows = outlineView.row(forItem: log)
        outlineView.reloadData(forRowIndexes: IndexSet(integer: rows), columnIndexes: IndexSet(integer: 0))
    }
}

extension ActiveChatOutlineViewController: NSOutlineViewDelegate {
    
}

class LogFileCellView : NSTableCellView {
    
    @IBOutlet weak var logNameField : NSTextField!
    @IBOutlet weak var lastLineField: NSTextField!
    @IBOutlet weak var unreadIndicator: NSImageView!
    
}
