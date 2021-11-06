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
    // TODO: implement b64 encoding for images (+ find a way to show the image in visual table)
    let dbConn: Connection?
    let clipboardTable: Table!
    var clipboardContentRaw: Expression<String?>
    var clipboardContentHTML: Expression<String?>
    var insertionTime: Expression<TimeInterval?>

    init() {
        do {
            // NOTE: db file-path is stored in /Users/$username$/Library/Containers/com.Uri-Yakir.Clipboard-Manager/Data
            self.dbConn = try Connection("db.sqlite3")
            self.clipboardTable = Table("clipboard")
            self.clipboardContentRaw = Expression<String?>("CLIPBOARD_CONTENT_RAW")
            self.clipboardContentHTML = Expression<String?>("CLIPBOARD_CONTENT_HTML")
            self.insertionTime = Expression<TimeInterval?>("INSERTION_TIME")
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
            } else { print(error) }
        }
    }

    func insertCopiedValueToDB(copiedObject: ClipboardCopiedObject, withCompletion completion: @escaping (_ success: Bool) -> Void) {
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
        var clipboardHistoryList: [ClipboardCopiedObject] = []
        do {
            let clipboardHistory = try self.dbConn?.prepare("SELECT * FROM clipboard ORDER BY INSERTION_TIME desc")
            for row in clipboardHistory! {
                clipboardHistoryList.append(ClipboardCopiedObject(copiedValueRaw: (row[0] as? String), copiedValueHTML: (row[1] as? String)))
            }
            return clipboardHistoryList
        } catch {
            fatalError("failed to grab clipboard history from database")
        }
    }
}
