//
//  SelectViewController.swift
//  RandomNumber
//
//  Created by ljy on 02/05/2019.
//  Copyright © 2019 ljy. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class SelectViewController: UIViewController {

    var arrayWin:[NSManagedObject]?
    var arrayNumber:[Int]! = []
    let max:Int = 45
    
    var result:[Int] = []
    var currentNo = 0
    var arraySaved:[NSManagedObject]?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...max {
            arrayNumber.append(i)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.saveTableView.delegate = self
        self.saveTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ConnectionManager.shared.checkNumber {
            self.arrayWin = DBManager.shared.fetch(entityName: "Win", limit: 50)
            self.arraySaved = DBManager.shared.fetch(entityName: "Saved")
            
            var pred = NSPredicate(format: "result == ''")
            let arrayNoCheck = DBManager.shared.select(entityName: "Saved", pred: pred)
            
            if let arrayNoCheck = arrayNoCheck {
                var noSet = Set<Int>()
                for value in arrayNoCheck {
                    noSet.insert(Int((value as! Saved).no))
                }
                
                for no in noSet {
                    pred = NSPredicate(format: "no == %d", no)
                    if let result = DBManager.shared.select(entityName: "Win", pred: pred) {
                       self.checkResult(result: (result[0] as! Win))
                    }else{
                        self.saveTableView.reloadData()
                    }
                }
            }else{
                self.saveTableView.reloadData()
            }
        }
        
//        let last = arrayWin?.first as! Win
//        LoadingView.shared.show()
//        request(currentIndex: Int(last.no))
    }
    
    func checkResult(result:Win){
        let pred = NSPredicate(format: "no == %d", result.no)
        let array = DBManager.shared.select(entityName: "Saved", pred: pred)
        if let array = array{
            for v in array {
                let vc = (v as! Saved)
                var match:Int = 0
                
                if vc.nm1 == result.nm1 {
                    match += 1
                }
                if vc.nm2 == result.nm2 {
                    match += 1
                }
                if vc.nm3 == result.nm3 {
                    match += 1
                }
                if vc.nm4 == result.nm4 {
                    match += 1
                }
                if vc.nm5 == result.nm5 {
                    match += 1
                }
                if vc.nm6 == result.nm6 {
                    match += 1
                }
                
                switch match {
                case 3 :
                    break
                case 4:
                    break
                case 5:
                    break
                case 6:
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBAction func makeNumber(_ sender: Any) {
        result = getNumbers()
        self.tableView.reloadData()
    }
    
    @IBAction func onSaved(_ sender: Any) {
        if result.count == 0 {
            return
        }
        
        var isAdd = true
        if arraySaved?.count ?? 0 > 0 {
            let pred = NSPredicate(format: "no == %d", currentNo)
            
            if let select = DBManager.shared.select(entityName: "Saved", pred: pred) {
                for v in select {
                    let value = v as! Saved
                    var count = 0
                    var arrayValue:[Int] = []
                    
                    arrayValue.append(Int(value.nm1))
                    arrayValue.append(Int(value.nm2))
                    arrayValue.append(Int(value.nm3))
                    arrayValue.append(Int(value.nm4))
                    arrayValue.append(Int(value.nm5))
                    arrayValue.append(Int(value.nm6))
                    
                    for i in result {
                        if result[i] == arrayValue[i] {
                            count += 1
                        }
                    }
                    
                    if count == result.count {
                        isAdd = false
                        break
                    }
                }
            }
        }
        
        if isAdd {
            let entity = DBManager.shared.makeEntity(entityName: "Saved")
            if let entity = entity {
                
                (entity as! Saved).no = Int32(self.currentNo)
                (entity as! Saved).nm1 = Int16(result[0])
                (entity as! Saved).nm2 = Int16(result[1])
                (entity as! Saved).nm3 = Int16(result[2])
                (entity as! Saved).nm4 = Int16(result[3])
                (entity as! Saved).nm5 = Int16(result[4])
                (entity as! Saved).nm6 = Int16(result[5])
                
                arraySaved?.append(entity)
                DBManager.shared.save()
                self.saveTableView.reloadData()
            }
        }
        
    }
    
//    func request(currentIndex:Int){
//        let url:String = "https://www.nlotto.co.kr/common.do?method=getLottoNumber&drwNo="
//        let index = currentIndex + 1
//        let requestUrl:String = "\(url)\(index)"
//
//        Alamofire.request(requestUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"]).validate(statusCode: 200..<300).responseJSON(completionHandler: {
//            response in
//            if let value:Dictionary = response.result.value as? Dictionary<String, Any> {
//                print(value)
//                if value["returnValue"] as! String == "success" {
//                    self.request(currentIndex: index)
//                }else{
//                    //fail
//                    self.currentNo = index
//                    LoadingView.shared.hide()
//                }
//            }else{
//                LoadingView.shared.hide()
//            }
//        })
//    }
//
//    func fetch() -> [NSManagedObject]? {
//        guard let managedContext = Utils.getContext() else {
//            return nil
//        }
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Win")
//        let sort = NSSortDescriptor(key: #keyPath(Win.no), ascending: false)
//
//        fetchRequest.sortDescriptors = [sort]
//        fetchRequest.fetchLimit = 50
//
//        do {
//            return try managedContext.fetch(fetchRequest)
//        } catch let error as NSError {
//            print("error : \(error)")
//            return nil
//        }
//    }
    
    func getNumbers() -> [Int]{
        var arrayRandom:[Int] = []
        if let arrayWin = self.arrayWin {
            arrayRandom.append(contentsOf: getFirst(array: arrayWin))
            var arrayOther:[Int] = []
            
            for value in arrayNumber {
                var isAdd = true
                for first in arrayRandom {
                    if first == value {
                        isAdd = false
                        break
                    }
                }
                if isAdd {
                    arrayOther.append(value)
                }
            }
            arrayOther.shuffle()
            arrayRandom.append(contentsOf: arrayOther[0..<10])
            arrayRandom.shuffle()
            
            let arrayResult = arrayRandom[0..<6]
            print("aR : \(arrayRandom)")
            print("aO : \(arrayOther)")
            print("result : \(arrayResult.sorted())")
            
            return arrayResult.sorted()
        }
        return arrayRandom
    }

    func getFirst(array:[NSManagedObject]) -> [Int]{
        var dic = Dictionary<Int,Int>()
        
        for i in 1...max {
            dic[i] = 0
        }
        
        for data in array {
            let win = data as! Win
            dic[Int(win.nm1)] = dic[Int(win.nm1)]! + 1
            dic[Int(win.nm2)] = dic[Int(win.nm2)]! + 1
            dic[Int(win.nm3)] = dic[Int(win.nm3)]! + 1
            dic[Int(win.nm4)] = dic[Int(win.nm4)]! + 1
            dic[Int(win.nm5)] = dic[Int(win.nm5)]! + 1
            dic[Int(win.nm6)] = dic[Int(win.nm6)]! + 1
            dic[Int(win.bonus)] = dic[Int(win.bonus)]! + 1
        }
        
        let sortArray = Array(dic).sorted{ $0.value > $1.value}
        print("sort : \(sortArray)")
        var result:[Int]! = []
        for i in 0...14 {
            let data = sortArray[i]
            result.append(data.key)
        }
        print("sort result : \(result!)")
        return result
    }
    
}

extension SelectViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return result.count == 0 ? 0 : 1
        }else{
            return self.arraySaved?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "\(WinNumberCell.self)") as! WinNumberCell
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        
        if tableView == self.tableView {
            cell.labelNo.text = "\(self.currentNo)."
            cell.label_1.text = "\(result[0])"
            cell.label_2.text = "\(result[1])"
            cell.label_3.text = "\(result[2])"
            cell.label_4.text = "\(result[3])"
            cell.label_5.text = "\(result[4])"
            cell.label_6.text = "\(result[5])"
        }else{
            let data = self.arraySaved![indexPath.row] as! Saved
            cell.labelNo.text = "\(data.no)."
            cell.label_1.text = "\(data.nm1)"
            cell.label_2.text = "\(data.nm2)"
            cell.label_3.text = "\(data.nm3)"
            cell.label_4.text = "\(data.nm4)"
            cell.label_5.text = "\(data.nm5)"
            cell.label_6.text = "\(data.nm6)"
        }
        
        return cell
    }
}

extension SelectViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.saveTableView {
            let headerView:WinNumberCell = self.tableView.dequeueReusableCell(withIdentifier: "\(WinNumberCell.self)") as! WinNumberCell
            headerView.backgroundColor = UIColor.lightGray
            headerView.labelNo.text = "회차"
            headerView.label_1.text = "1"
            headerView.label_2.text = "2"
            headerView.label_3.text = "3"
            headerView.label_4.text = "4"
            headerView.label_5.text = "5"
            headerView.label_6.text = "6"
            headerView.label_7.text = "결과"
            return headerView
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            return 0
        }else{
            return 40
        }
        
    }
}
