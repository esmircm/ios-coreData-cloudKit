//
//  CloudKitUploader.swift
//  Test_MsterTSA_5
//
//  Created by Esmir Cabrera on 19/1/19.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

struct CloudKitUploader {
    
    private let moc: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        moc = context
    }
    
    
    func upload() {
        
        let request = Country.fetchRequest() as NSFetchRequest<Country>
        
        if let results = try? moc.fetch(request) {
            
            let container = CKContainer.default()
            let db = container.publicCloudDatabase
            
            for country in results {
                
                let recordID = CKRecord.ID(recordName: country.code!)
                
                let record = CKRecord(recordType: "Countries", recordID: recordID)
                
                record["name"] = country.name! as NSString
                
                db.save(record) { (record, error) in
                    
                    
                    guard error == nil else {
                        
                        debugPrint("Error al grabar pais")
                        return
                        
                    }
                    
                    debugPrint("Guardado")
                    
                }
                
            }
            
            debugPrint("Fin del guardado")
            
        }
        
    }
    
    
}
