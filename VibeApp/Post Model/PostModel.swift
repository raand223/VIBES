

import Foundation


class PostModel: NSObject {
    var key: String // necessary to track node for delete/edit purpose
    var caption : String?
    var posturl  : String?
    var userPostId : String?
    
    init(key: String, dic: [String: Any]) {
        self.key = key
        
        self.caption = dic["caption"] as? String
        self.posturl = dic["postURL"] as? String
        self.userPostId = dic["userId"] as? String
    }
}
