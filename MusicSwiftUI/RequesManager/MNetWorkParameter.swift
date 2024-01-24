

import UIKit
import Alamofire

class MNetWorkParameter: NSObject {
    var methodType : HTTPMethod = .post
    var url : String = ""
    var parameters : [String : Any] = [:]
    var isNestedData : Bool = false
    var encoding : ParameterEncoding = URLEncoding.default
    var useBaseUrl : Bool = false
    var file : String = "0"
    var lineNum : Int = 0
    var successCallBack : ((_ result:[String: Any]) -> ())?
    var failureCallBack : ((_ error: Error) -> ())?
}
