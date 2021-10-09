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

    init() {
        do {
            self.dbConn = try Connection("db.sqlite3")
            self.setupTable()
        } catch {
            self.dbConn = nil
            print(error)
        }
    }

    private func setupTable() {
        let clipboardTable = Table("clipboard")
        do {
            _ = try dbConn!.scalar(clipboardTable.exists)
//            let insert = clipboardTable.insert(strRepr <- "Clipboard text 1")
//            let insert2 = clipboardTable.insert(strRepr <- "Clipboard text 2")
//            let insert3 = clipboardTable.insert(strRepr <- "Clipboard text 3")
//            _ = try dbConn?.run(insert)
//            _ = try dbConn?.run(insert2)
//            _ = try dbConn?.run(insert3)
//            try print(dbConn?.scalar(clipboardTable.count))
        } catch {
            if "\(error)".starts(with: "no such table") {  // hacky way to get error message as a string and test against its value
                do {
                    let strRepr = Expression<String>("STR_REPR")
                    try dbConn?.run(clipboardTable.create { type in
                        type.column(strRepr)
                    })
                } catch {}
            } else { print(error) }
        }
    }

    func dummy() {
        // TODO: remove this function when Constants variable is referenced in one of the VC
    }
}
