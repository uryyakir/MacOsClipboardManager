//
//  DatabaseHandler.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 09/10/2021.
//

import Foundation
import SQLite

class DatabaseHandler {
    // TODO: when copying something to clipboard - push it to visual history and database
    // TODO: implement total Mb db size, when size is surpassed - delete oldest records until size falls below threshold
    // TODO: implement b64 encoding for images (+ find a way to show the image in visual table)
    // TODO: migrate application tableview to populating from database
    let dbConn: Connection?
    let clipboardTable: Table!
    var clipboardContent: Expression<String>
    var insertionTime: Expression<TimeInterval?>

    init() {
        do {
            // NOTE: db file-path is stored in /Users/$username$/Library/Containers/com.Uri-Yakir.Clipboard-Manager/Data
            self.dbConn = try Connection("db.sqlite3")
            self.clipboardTable = Table("clipboard")
            self.clipboardContent = Expression<String>("CLIPBOARD_CONTENT")
            self.insertionTime = Expression<TimeInterval?>("INSERTION_TIME")
            self.setupTable()
        } catch {
            fatalError("failed to initialize DatabaseHandler")
        }
    }

    private func setupTable() {
        do {
            _ = try dbConn!.scalar(self.clipboardTable.exists)
        } catch {
            if "\(error)".starts(with: "no such table") {  // hacky way to get error message as a string and test against its value
                print("creating clipboard table")
                do {
                    try dbConn?.run(self.clipboardTable.create { type in
                        type.column(self.clipboardContent)
                        type.column(self.insertionTime)
                    })
                } catch {}
            } else { print(error) }
        }
    }

    func insertCopiedValueToDB(copiedValue: String, withCompletion completion: @escaping (_ success: Bool) -> Void) {
        do {
            let insertRecord = self.clipboardTable.insert(self.clipboardContent <- copiedValue, self.insertionTime <- NSDate().timeIntervalSince1970)
            _ = try self.dbConn?.run(insertRecord)
            completion(true)
            return
        } catch {
            fatalError("failed to insert record to db file")
        }
    }

    func dummy() {
        // TODO: remove this function when Constants variable is referenced in one of the VC
    }
}
