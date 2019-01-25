//
//  CountriesDonloader.swift
//  TestMasterTsa_3
//
//  Created by Marro Gros Gabriel on 24/11/2018.
//  Copyright © 2018 Marro Gros Gabriel. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

struct CountryDownloader {
    
    struct CountryObj: Codable {
        let name:String
        let code: String
        
        enum CodingKeys: String, CodingKey {
            case name = "fullname"
            case code = "ianacode"
        }
    }
    
    private let countriesURL = "http://apptones.net/test02_assets/Countries.json"
    
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func download(completion:@escaping ()->Void) {
        
        let container = CKContainer.default()
        let db = container.publicCloudDatabase
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Countries", predicate: predicate)
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.context
        
        let op = CKQueryOperation(query: query)
        
        
        func perRecord(_ record: CKRecord) { // funcion para hacer la consulta la primera consulta
            
            let code = record.recordID.recordName as String
            
            let req = Country.fetchRequest() as NSFetchRequest<Country> // busco cloud kit
            
            req.predicate = NSPredicate(format: "code == \( code )")
            
            if let results = try? context.fetch(req),
                results.count > 0 {
                
                let name = record["name"] as! NSString
                
                if name as String != results.first?.name {
                    results.first?.name = name as String
                }
            } else {
                
                if let country = NSEntityDescription.insertNewObject(forEntityName: "Country", into: context) as? Country {
                    country.name = record["name"] as? String
                    country.code = record.recordID.recordName
                }
                
            }
        }
        
        op.recordFetchedBlock = perRecord // ejecutando funcion
        
        
        func completionBlock(cursor: CKQueryOperation.Cursor?, error: Error?) { // funcion para terminar la consulta
            
            guard error == nil else {
                debugPrint("error al guardar")
                return
            }
            
            if cursor != nil { // si no hay mas cursores se vuelve a consultar todo de nuevo
                let newOp = CKQueryOperation(cursor: cursor!)
                newOp.recordFetchedBlock = perRecord
                newOp.queryCompletionBlock = completionBlock
            }
            
        }
        
        
        op.queryCompletionBlock = completionBlock // ejecuntando funcion
        
        db.add(op)
        
        
        
        
        
        
        
        
        
        
        
        let session = URLSession.shared
        
        let bkTask = UIApplication.shared.beginBackgroundTask {
            debugPrint("Download stopped")
        }
        
        let req = URLRequest(url: URL(string:countriesURL)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 0.0)
        
        let task = session.dataTask(with: req)  {
            (data, response, error) in
            
            guard error == nil && data != nil else {
                
                completion()
                DispatchQueue.main.async {
                    UIApplication.shared.endBackgroundTask(bkTask)
                }
                return
            }
            
            
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.parent = self.context
            
            context.perform {
                if let countries = try? JSONDecoder().decode([CountryObj].self, from: data!) {
                    
                    var currentCodes: [String] = []
                    
                    for countryObj in countries {
                        
                        currentCodes.append(countryObj.code)
                        
                        let req = Country.fetchRequest() as NSFetchRequest<Country>
                        req.predicate = NSPredicate(format: "code == %@", countryObj.code) // busca en core date
                        
                        if let result = try? context.fetch(req),
                            result.count > 0 {
                            if countryObj.name != result.first!.name {
                                result.first!.name = countryObj.name
                            }
                        } else { // guarda en core date
                            if let country = NSEntityDescription.insertNewObject(forEntityName: "Country", into: context) as? Country {
                                country.name = countryObj.name
                                country.code = countryObj.code
                            }
                        }
                    }
                    
                    let req = Country.fetchRequest() as NSFetchRequest<Country>
                    req.predicate = NSPredicate(format: "!(code in %@)", currentCodes)
                    if let result = try? context.fetch(req) {
                        for country in result {
                            context.delete(country)
                        }
                    }
                }
                
                try? context.save()
                
                completion()
                
                DispatchQueue.main.async {
                    UIApplication.shared.endBackgroundTask(bkTask)
                }
            }
        }
        
        task.resume()
        
    }
    
}
