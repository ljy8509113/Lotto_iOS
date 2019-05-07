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

class WinNumberCell:UITableViewCell{
    @IBOutlet weak var labelNo: UILabel!
    @IBOutlet weak var label_1: UILabel!
    @IBOutlet weak var label_2: UILabel!
    @IBOutlet weak var label_3: UILabel!
    @IBOutlet weak var label_4: UILabel!
    @IBOutlet weak var label_5: UILabel!
    @IBOutlet weak var label_6: UILabel!
    @IBOutlet weak var label_7: UILabel!
    
    func setData(value:Win){
        labelNo.text = "\(value.no)"
        label_1.text = "\(value.nm1)"
        label_2.text = "\(value.nm2)"
        label_3.text = "\(value.nm3)"
        label_4.text = "\(value.nm4)"
        label_5.text = "\(value.nm5)"
        label_6.text = "\(value.nm6)"
        label_7.text = "\(value.bonus)"
    }
}

class ViewController: UIViewController {
//    var _session: URLSession? = nil
    var resultData:[NSManagedObject]?
    let dateFormatterGet = DateFormatter()
    var isSave = false
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        tableView.delegate = self
        tableView.dataSource = self
        
        resultData = fetch()
        let lastSaveNo:Int! = resultData?.count == 0 ? 1 : (Int)((resultData?.first as! Win).no)
        
        request(currentIndex: lastSaveNo)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) 
        LoadingView.shared.show()
    }
    
    func request(currentIndex:Int){
        let url:String = "https://www.nlotto.co.kr/common.do?method=getLottoNumber&drwNo="
        let requestUrl:String = "\(url)\(currentIndex+1)"
        
        Alamofire.request(requestUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"]).validate(statusCode: 200..<300).responseJSON(completionHandler: {
            response in
            if let value:Dictionary = response.result.value as? Dictionary<String, Any> {
                print(value)
                if value["returnValue"] as! String == "success" {
                    
                    let entity = NSEntityDescription.entity(forEntityName: "Win", in: Utils.getContext()!)
                    if let entity = entity {
                        let person = NSManagedObject(entity: entity, insertInto: Utils.getContext()) as! Win
                        person.no = value["drwNo"] as! Int32
                        person.nm1 = value["drwtNo1"] as! Int16
                        person.nm2 = value["drwtNo2"] as! Int16
                        person.nm3 = value["drwtNo3"] as! Int16
                        person.nm4 = value["drwtNo4"] as! Int16
                        person.nm5 = value["drwtNo5"] as! Int16
                        person.nm6 = value["drwtNo6"] as! Int16
                        person.bonus = value["bnusNo"] as! Int16
                        person.date = self.dateFormatterGet.date(from: value["drwNoDate"] as! String)
                        
                        do{
                            try Utils.getContext()?.save()
                            self.request(currentIndex: currentIndex+1)
                        } catch let error as NSError {
                            print("error: \(error)")
                        }
                    }
                }else{
                    //fail
                    self.resultData = self.fetch()
                    self.tableView.reloadData()
                    LoadingView.shared.hide()
                }
            }else{
                LoadingView.shared.hide()
            }
        })
    }
    
    func fetch() -> [NSManagedObject]? {
        guard let managedContext = Utils.getContext() else {
            return nil
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Win")
        let sort = NSSortDescriptor(key: #keyPath(Win.no), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("error : \(error)")
            return nil
        }
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
        headerView.labelNo.text = "title"
        headerView.label_1.text = "title1"
        headerView.label_2.text = "title2"
        headerView.label_3.text = "title3"
        headerView.label_4.text = "title4"
        headerView.label_5.text = "title5"
        headerView.label_6.text = "title6"
        headerView.label_7.text = "title7"
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


