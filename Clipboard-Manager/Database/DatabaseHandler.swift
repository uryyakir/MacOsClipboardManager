//
//  DatabaseHandler.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 09/10/2021.
//

import Foundation
import SQLite

class DatabaseHandler {
    let dbConn: Connection?
    let clipboardTable: Table!
    var clipboardContentRaw: Expression<String?>
    var clipboardContentHTML: Expression<String?>
    var insertionTime: Expression<TimeInterval?>

    init() {
        do {
            // NOTE: db file-path is stored in /Users/$username$/Library/Containers/com.Uri-Yakir.Clipboard-Manager/Data
            self.dbConn = try Connection(DBConstants.DBFilename.rawValue)
            self.clipboardTable = Table(DBConstants.tableName.rawValue)
            self.clipboardContentRaw = Expression<String?>(DBConstants.clipboardContentRawCol.rawValue)
            self.clipboardContentHTML = Expression<String?>(DBConstants.clipboardContentHTMLCol.rawValue)
            self.insertionTime = Expression<TimeInterval?>(DBConstants.insertionTimeCol.rawValue)
            self.setupTable()
        } catch {
            fatalError("failed to initialize DatabaseHandler!\n\(error)")
        }
    }

    var dbFileSize: Int {
        do {
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let dbFileURL = dir.first?.deletingLastPathComponent().appendingPathComponent(DBConstants.DBFilename.rawValue)
            let fileResource = try dbFileURL!.resourceValues(forKeys: [.fileSizeKey])
            return fileResource.fileSize!
        } catch {
            fatalError("failed to get DBFile size!\n\(error)")
        }
    }

    private func setupTable() {
        do {
            _ = try self.dbConn!.scalar(self.clipboardTable.exists)
        } catch {
            if "\(error)".starts(with: "no such table") {  // hacky way to get error message as a string and test against its value
                print("creating clipboard table")
                do {
                    try self.dbConn?.run(self.clipboardTable.create { type in
                        type.column(self.clipboardContentRaw)
                        type.column(self.clipboardContentHTML)
                        type.column(self.insertionTime)
                    })
                } catch {}
            } else {
                fatalError("uncaught error raised from table setup!\n\(error)")
            }
        }
    }

    func insertCopiedValueToDB(copiedObject: ClipboardCopiedObject, withCompletion completion: @escaping (_ success: Bool) -> Void) {
        // Storing a user-copied value into the SQLite database
        do {
            let insertRecord = self.clipboardTable.insert(
                self.clipboardContentRaw <- copiedObject.copiedValueRaw,
                self.clipboardContentHTML <- copiedObject.copiedValueHTML,
                self.insertionTime <- NSDate().timeIntervalSince1970
            )
            _ = try self.dbConn?.run(insertRecord)
            completion(true)
            return
        } catch {
            fatalError("failed to insert record to db file!\n\(error)")
        }
    }

    func grabAllClipboardHistory() -> [ClipboardCopiedObject] {
        // on application initiation - grab all clipboard history, and use it to populate application table
        var clipboardHistoryList: [ClipboardCopiedObject] = []
        do {
            let clipboardHistory = try self.dbConn?.prepare(DBQueries.selectAllHistoryQuery)
            for row in clipboardHistory! {
                clipboardHistoryList.append(ClipboardCopiedObject(copiedValueRaw: (row[0] as? String), copiedValueHTML: (row[1] as? String)))
            }
            return clipboardHistoryList
        } catch {
            fatalError("failed to grab clipboard history from database!\n\(error)")
        }
    }

    private func deleteOldestRecord() {
        do {
            let oldestRecordId = try self.dbConn?.prepare(DBQueries.getOldestRecordIdQuery)
            let rowId = (oldestRecordId!.map { $0 }[0][0] as? Int64)!
            let oldestRecord = self.clipboardTable.filter(rowid == rowId)
            try self.dbConn!.run(oldestRecord.delete())
            try self.dbConn?.vacuum()  // clear up deleted space to update DB file size
        } catch {
            fatalError("failed to delete oldest record from database!\n\(error)")
        }
    }

    func trimDatabaseRecords() {
        /*
         We don't want the database to get too large - this is unnecessary and slows the launch of the application.
         I've set some size threshold for the database - whenever the database surpasses this limit,
         it'll trim older records until its size is back to acceptable range.
         */
        while Double(self.dbFileSize) / DBQueries.bitsToMBConversionRatio > DBQueries.maxAllowedDBFileSizeMB {
            self.deleteOldestRecord()
            let arrayController = Constants.mainVC.clipboardTableVC.arrayController
            arrayController.remove(atArrangedObjectIndexes: IndexSet([
                (arrayController.arrangedObjects as? [Any])!.count - 1
            ]))
        }
    }
}
