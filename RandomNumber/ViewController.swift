//
//  ViewController.swift
//  RandomNumber
//
//  Created by ljy on 02/05/2019.
//  Copyright © 2019 ljy. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ViewController: UIViewController {
//    var _session: URLSession? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url:String = "https://www.nlotto.co.kr/common.do?method=getLottoNumber&drwNo=1"
//        let url:String = "https://api.bithumb.com/public/ticker/BTC"

//        let request = URLRequest(url: URL(string: url)!)
//        self.session.dataTask(with: request) { (_, response, error) in
//            if let error = error as NSError? {
////                NSLog("transport error, error: %@ / %d", error.domain, error.code)
//                print("error : \(error)")
//                return
//            }
//            let response = response as! HTTPURLResponse
////            NSLog("response, statusCode: %d", response.statusCode)
//            print("response : \(response.statusCode)")
//            print("response : \(response.description)")
//            }.resume()
        
        
        Alamofire.SessionManager.default.delegate.taskDidReceiveChallenge = { session, _, challenge in
            let method = challenge.protectionSpace.authenticationMethod
            let host = challenge.protectionSpace.host
            NSLog("challenge %@ for %@", method, host)
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
        
        Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"]).validate(statusCode: 200..<300).responseJSON(completionHandler: {
            response in
            if let value:Dictionary = response.result.value as? Dictionary<String, Any> {
                print(value)
                if value["returnValue"] as! String == "success" {

                    let entity = NSEntityDescription.entity(forEntityName: "Win", in: Utils.getContext()!)
                    if let entity = entity {
                        var person = NSManagedObject(entity: entity, insertInto: Utils.getContext())
                    }
                    
//                    value["drwNo"]
//                    value["bnusNo"]
//                    value["drwtNo1"]
//                    value["drwtNo2"]
//                    value["drwtNo3"]
//                    value["drwtNo4"]
//                    value["drwtNo5"]
//                    value["drwtNo6"]
//                    value["drwNoDate"]
                }else{
                    //fail
                }
            }
        })
        
        
    }
}

//extension ViewController :URLSessionDelegate{
//    var session: URLSession {
//        if let session = self._session {
//            return session
//        }
//        let config = URLSessionConfiguration.default
//        config.requestCachePolicy = .reloadIgnoringLocalCacheData
//        let session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
//        self._session = session
//        return session
//    }
//
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        let method = challenge.protectionSpace.authenticationMethod
//        let host = challenge.protectionSpace.host
//        NSLog("challenge %@ for %@", method, host)
//        switch (method, host) {
////        case (NSURLAuthenticationMethodServerTrust, "self-signed.badssl.com"):
//        case (NSURLAuthenticationMethodServerTrust, "www.nlotto.co.kr") :
//            let trust = challenge.protectionSpace.serverTrust!
//            let credential = URLCredential(trust: trust)
//            completionHandler(.useCredential, credential)
//        default:
//            completionHandler(.performDefaultHandling, nil)
//        }
//    }
//}


