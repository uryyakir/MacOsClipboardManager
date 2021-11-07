//
//  DatabaseHandler.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 09/10/2021.
//

import Foundation
import SQLite

class DatabaseHandler {
    // TODO: implement total Mb db size, when size is surpassed - delete oldest records until size falls below threshold
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
            fatalError("failed to initialize DatabaseHandler")
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
                print(error)
                fatalError("uncaught error raised from table setup")
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
            fatalError("failed to insert record to db file")
        }
    }

    func grabAllClipboardHistory() -> [ClipboardCopiedObject] {
        // on application initiation - grab all clipboard history, and use it to populate application table
        var clipboardHistoryList: [ClipboardCopiedObject] = []
        do {
            let clipboardHistory = try self.dbConn?.prepare(DBConstants.selectAllHistoryQuery.rawValue)
            for row in clipboardHistory! {
                clipboardHistoryList.append(ClipboardCopiedObject(copiedValueRaw: (row[0] as? String), copiedValueHTML: (row[1] as? String)))
            }
            return clipboardHistoryList
        } catch {
            fatalError("failed to grab clipboard history from database")
        }
    }
}
