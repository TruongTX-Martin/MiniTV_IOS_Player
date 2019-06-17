//
//  PlayerAPI.swift
//  msplayer_ios
//
//  Created by neo on 14/06/2019.
//  Copyright © 2019 neo. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireLogging

let API_HOST = "https://stage-api.minischool.co.kr/msapi/v2"
let BOOK_ID = 554
let TOKEN = "e4a0a4be-4924-4557-a28a-025ade7451b1"



struct BookInfo: Codable {
    let result: RawData
//    let b: String
}

struct RawData: Codable {
    let rawData: String
  
    enum CodingKeys: String, CodingKey {
        case rawData = "raw_data"
    }
}


func findBookInfo(completion: @escaping (Bool, Book?) -> Void) {
    
    let parameters: Parameters = [
        "book_id": BOOK_ID,
        "token": TOKEN,
        "class_key": "aa"
    ]
    
    Alamofire.request(API_HOST + "/book/findBookInfo",method: .post, parameters: parameters, encoding: JSONEncoding.default)
        .log(level: .simple)
        .response { response in
            //debugPrint("All Response Info: \(response.data)")
            
            guard let data = response.data else {
                print("Error while findBookInfo: \(String(describing:response.error))")
                completion(false, nil)
                return
            }
            
//            if let JSON = response.result.value {
//                //print("JSON: \(JSON)")
//                let r: NSDictionary = JSON as! NSDictionary
//
//                //example if there is an id
//                let result = r.object(forKey: "result")
//                //print("result \(result!)" )
//
//                let rr: NSDictionary = result as! NSDictionary
//                let result2 = rr.object(forKey: "raw_data")
//                print("result \(result2!)" )
//
//            }
            
            
            do {
                let bookInfo = try! JSONDecoder().decode(BookInfo.self, from: data)
                //print(bookInfo.result.rawData) // Sample1(a: "aa", b: "bb")
                let book = try! JSONDecoder().decode(Book.self, from: bookInfo.result.rawData.data(using: .utf8)!)
                print(book)
                completion(true, book)
            } catch {
                print("error \(error.localizedDescription)")
                completion(false, nil)
            }
    }
}


//
//// All three of these calls are equivalent
//let service = Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters)
//
//
//    service.responseJSON { response in
//        print("Request: \(String(describing: response.request))")   // original url request
//        print("Response: \(String(describing: response.response))") // http url response
//        print("Result: \(response.result)")                         // response serialization result
//
//        if let json = response.result.value {
//            print("JSON: \(json)") // serialized json response
//        }
//
//        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//            print("Data: \(utf8Text)") // original server data as UTF8 string
//        }
//}


//import Siesta
//
//
//let PlayerAPI = _PlayerAPI()
//
//
//
//class _PlayerAPI: Service {
//    init() {
//        super.init(baseURL: "https://stage-api.minischool.co.kr/msapi/v2")
//        SiestaLog.Category.enabled = .common
//
//    }
//
//
//    func findBookInfo(bookId: Int, token: String) -> Request {
//        return
//            resource("/book/findBookInfo")
//            .request(.post, json: ["book_id": bookId, "token": token])
//
//    }
//
//
//    var profile: Resource { return resource("/profile") }
//    var items:   Resource { return resource("/items") }
//
//    func item(id: String) -> Resource {
//        return items.child(id)
//    }
//
//    //var bookInfo:
//}


