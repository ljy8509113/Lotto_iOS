//
//  ConnectionManager.swift
//  RandomNumber
//
//  Created by ljy on 09/05/2019.
//  Copyright © 2019 ljy. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ConnectionManager: NSObject {
    var dateFormatterGet:DateFormatter!
    var saveData:[NSManagedObject] = []
    
    static var shared:ConnectionManager = {
        let instance = ConnectionManager()
        instance.dateFormatterGet = DateFormatter()
        instance.dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        Alamofire.SessionManager.default.delegate.taskDidReceiveChallenge = { session, _, challenge in
            let method = challenge.protectionSpace.authenticationMethod
            let host = challenge.protectionSpace.host
            //            NSLog("challenge %@ for %@", method, host)
            switch (method, host) {
            //        case (NSURLAuthenticationMethodServerTrust, "self-signed.badssl.com"):
            case (NSURLAuthenticationMethodServerTrust, "www.nlotto.co.kr") :
                let trust = challenge.protectionSpace.serverTrust!
                let credential = URLCredential(trust: trust)
                //                completionHandler(.useCredential, credential)
                return(.useCredential, credential)
            default:
                var disposition: URLSession.AuthChallengeDisposition = .useCredential
                var credential: URLCredential = URLCredential()
                
                if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust){
                    disposition = URLSession.AuthChallengeDisposition.useCredential
                    credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                }
                return(disposition, credential)
                //                completionHandler(.performDefaultHandling, nil)
            }
        }
        
        return instance
    }()
    
    func checkNumber(finish:@escaping (() -> Void)){
        LoadingView.shared.show()
        let lastNo = DBManager.shared.entityCount(entityName: "Win")
        request(currentIndex: lastNo, finish: finish)
    }
    
    func request(currentIndex:Int, finish:@escaping (() -> Void)){
        let url:String = "https://www.nlotto.co.kr/common.do?method=getLottoNumber&drwNo="
        let requestUrl:String = "\(url)\(currentIndex+1)"
        
        Alamofire.request(requestUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"]).validate(statusCode: 200..<300).responseJSON(completionHandler: {
            response in
            if let value:Dictionary = response.result.value as? Dictionary<String, Any> {
                print(value)
                if value["returnValue"] as! String == "success" {
                    if let person = DBManager.shared.makeEntity(entityName: "Win") {
                        let p = person as! Win
                        p.no = value["drwNo"] as! Int32
                        p.nm1 = value["drwtNo1"] as! Int16
                        p.nm2 = value["drwtNo2"] as! Int16
                        p.nm3 = value["drwtNo3"] as! Int16
                        p.nm4 = value["drwtNo4"] as! Int16
                        p.nm5 = value["drwtNo5"] as! Int16
                        p.nm6 = value["drwtNo6"] as! Int16
                        p.bonus = value["bnusNo"] as! Int16
                        p.date = self.dateFormatterGet.date(from: value["drwNoDate"] as! String)
                        self.saveData.append(p)
                        
                    }
                    self.request(currentIndex: currentIndex+1, finish: finish)
                }else{
                    //fail
                    if self.saveData.count > 0 {
                        DBManager.shared.save()
                    }
                    LoadingView.shared.hide()
                    finish()
                }
            }else{
                LoadingView.shared.hide()
                finish()
            }
        })
    }
    
}
