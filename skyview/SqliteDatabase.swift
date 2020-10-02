//
//  SqliteDatabase.swift
//  Copyright © 2020 Tod Landis. All rights reserved.
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// 1.0

import SQLite3

class SqliteDatabase {
    var path:String? = nil
    var database: OpaquePointer? = nil

    init(_ path:String){
        self.path = path
    }
    
    func open() -> Bool {
        if(database != nil) {
            return true
        }
        if (sqlite3_open(path, &database) != SQLITE_OK) {
            print("ERROR:  unable to open database at \(path!)")
            database = nil;
            return false;
        }
        else {
            return true
        }
    }
    
    func close() {
        sqlite3_close(database)
        database = nil
    }
    
    /**
     Execute 'sql', e.g. an UPDATE or CREATE, on database 'db'.  Returns true for success, false for failure.
     
     Bracket this with calls to open() and close()
     */
    func execute(_ sql:String) {
        guard let database = database else {
            print("ERROR database is not open")
            return
        }
        
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            print("ERROR preparing \"\(sql)\"")
            sqlError();
            return
        }
        guard sqlite3_step(statement) == SQLITE_DONE else {
            print("ERROR stepping \(sql)")
            sqlError();
            return
        }
        sqlite3_finalize(statement)
        return
    }
    
    func queryForDouble(sql:String) -> Double {
        var ret:Double = Double.nan
        var statement: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            let state = sqlite3_step(statement)
            if (state == SQLITE_ROW) {
                ret = Double(sqlite3_column_double(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return ret;
    }
    
    func queryForDoubles(sql:String) -> [Double] {
        var ret = [Double]()
        var statement: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            var state = SQLITE_OK
            repeat {
                state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    ret.append( Double(sqlite3_column_double(statement, 0)))
                }
            } while (state == SQLITE_ROW)
        }
        sqlite3_finalize(statement)
        return ret;
    }
    
    func queryForInt(sql:String) -> Int? {
        var ret:Int? = nil
        var statement: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            let state = sqlite3_step(statement)
            if (state == SQLITE_ROW) {
                ret = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return ret;
    }
    
    func queryForDoubles3(sql:String) -> [(Double,Double,Double)] {
        var ret = [(Double,Double,Double)]()
        var statement: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    let x = Double(sqlite3_column_double(statement, 0))
                    let y = Double(sqlite3_column_double(statement, 1))
                    let z = Double(sqlite3_column_double(statement, 2))
                    ret.append((x,y,z))
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return ret;
    }

    
    func queryForInts(sql:String) -> [Int] {
        var ret = [Int]()
        var statement: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    let result = sqlite3_column_int64(statement, 0)
                    ret.append(Int(truncatingIfNeeded: result))
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return ret;
    }


    
    func queryForString(sql:String) -> String {
        var statement: OpaquePointer? = nil
        var ret:String = "***"
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            let state = sqlite3_step(statement)
            if (state == SQLITE_ROW) {
                // this is how to convert sqlite text to a stringd
                let result = sqlite3_column_text(statement, 0)
                if(result != nil) {
                    let val = String.init(cString:result!)
                    ret = val
                }
            }
        }
        sqlite3_finalize(statement);
        return ret;
    }
    
    func queryForStrings(sql:String) -> [String] {
        var ret = [String]()
        var statement: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    // this is how to convert sqlite text to a string
                    let result = sqlite3_column_text(statement, 0)
                    if(result != nil) {
                        let str = String.init(cString:result!)
                        ret.append(str)
                    }
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return ret;
    }
    
    func queryForKeyRaDec(sql:String) -> [(key:Int, ra:Double,dec:Double)] {
        var ret = [(key:Int, ra:Double,dec:Double)]()
        
        var statement: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    let key = Int(sqlite3_column_int64(statement, 0))
                    let x = Double(sqlite3_column_double(statement, 1))
                    let y = Double(sqlite3_column_double(statement, 2))
                    ret.append((key,x,y))
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return ret;
    }

    func queryForKeyXYZ(sql:String) -> [(key:Int, x:Double,y:Double,z:Double)] {
        var ret = [(key:Int, x:Double,y:Double,z:Double)]()
        
        var statement: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    let key = Int(sqlite3_column_int64(statement, 0))
                    let x = Double(sqlite3_column_double(statement, 1))
                    let y = Double(sqlite3_column_double(statement, 2))
                    let z = Double(sqlite3_column_double(statement, 3))
                    ret.append((key,x,y,z))
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return ret;
    }



    func sqlError() {
        print("SQL ERROR");
    }
}
