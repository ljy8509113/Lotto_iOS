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
    var resultData:[NSManagedObject]?
    let dateFormatterGet = DateFormatter()
    var isSave = false
    
    @IBOutlet weak var tableView: UITableView!
    
    var saveData:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) 
        LoadingView.shared.show()
        
        resultData = DBManager.shared.fetch(entityName: "Win")
        let lastSaveNo:Int! = resultData?.count == 0 ? 1 : (Int)((resultData?.first as! Win).no)
        
        request(currentIndex: lastSaveNo)
    }
    
    func request(currentIndex:Int){
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
                    self.request(currentIndex: currentIndex+1)
                    
//                        do{
//                            try Utils.getContext()?.save()
//                            self.request(currentIndex: currentIndex+1)
//                        } catch let error as NSError {
//                            print("error: \(error)")
//                        }
                    
                }else{
                    //fail
                    if self.saveData.count > 0 {
                        DBManager.shared.save()
                    }
                    
                    self.resultData = DBManager.shared.fetch(entityName: "Win")
                    self.tableView.reloadData()
                    LoadingView.shared.hide()
                }
            }else{
                LoadingView.shared.hide()
            }
        })
    }
    
    
    
}

extension ViewController :UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(WinNumberCell.self)") as! WinNumberCell
        
        let data = resultData![indexPath.row] as! Win
        cell.setData(value: data)
        
        return cell
    }
}

extension ViewController :UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:WinNumberCell = tableView.dequeueReusableCell(withIdentifier: "\(WinNumberCell.self)") as! WinNumberCell
        headerView.backgroundColor = UIColor.lightGray
        headerView.labelNo.text = "회차"
        headerView.label_1.text = "1"
        headerView.label_2.text = "2"
        headerView.label_3.text = "3"
        headerView.label_4.text = "4"
        headerView.label_5.text = "5"
        headerView.label_6.text = "6"
        headerView.label_7.text = "보너스"
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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


