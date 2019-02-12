//
//  FirstViewController.swift
//  Dev Portal
//
//  Created by Roger Lee on 8/2/19.
//  Copyright © 2019 Roger Lee. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire

/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
let kIssuer = "";

/*! @brief The OAuth client ID and client Secrete
 */
let kClientID = "";
let kClientSecret = "";

/*! @brief The OAuth redirect URI for the client @c kClientID.
 */
let kRedirectURI = "";

class FirstViewController: UIViewController {
    
    var oauthcode:String?
    var oauthstate:String?
    var accessToken:String?
    let uuid = UUID().uuidString
    @IBOutlet weak var statusLabel:UILabel?
    @IBOutlet weak var responseLabel:UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        verifyConfig()
    }
    
    func verifyConfig() {
    
        // The example needs to be configured with your own client details.
        assert(kClientID != "","Update kClientID with your own client ID.")
        assert(kClientSecret != "","Update kClientSecret with your own client Secret.")
        assert(kRedirectURI != "","Update kRedirectURI with your own redirect URI.")
    
    }
    
    @IBAction func openIDConnect() {
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let authorizationUrl = kIssuer + "/v1/identity/oauth/authorize?state=" + uuid + "&scope=openid%20profile&client_id=" + kClientID + "&client_secret=" + kClientSecret + "&response_type=code&redirect_uri=" + kRedirectURI
        
        let safariVC = SFSafariViewController(url: URL(string: authorizationUrl)!, configuration: config)
        safariVC.delegate = self as? SFSafariViewControllerDelegate
        safariVC.modalPresentationStyle = .currentContext
        present(safariVC, animated: false, completion: nil)
        
    }
    
    func setLink(_ urlString: String, code:String, state: String) {
        responseLabel?.text = urlString
        statusLabel?.text = "Authenticated"
        oauthcode = code
        oauthstate = state
    }
    
    @IBAction func exchangeToken() {
        
        let parameters = [
            "client_id": kClientID,
            "client_secret" : kClientSecret,
            "grant_type" : "authorization_code",
            "redirect_uri" : kRedirectURI,
            "state" : oauthstate!,
            "code" : oauthcode!
        ]
        
        let url = kIssuer + "/v1/identity/oauth/token"
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON
            { response in switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                
                let responseResult = JSON as! NSDictionary
                print(response.result)
                
                self.accessToken = responseResult["access_token"] as? String
                print(self.accessToken as Any)
                
                var jsonData: NSData?
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: responseResult, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
                    self.responseLabel?.text = NSString(data: jsonData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
                } catch _ {
                    jsonData = nil
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    @IBAction func getInfo() {
        
        let url = kIssuer + "/v1/identity/oauth/userinfo"
        
        let headers = [
            "Authorization": "Bearer " + accessToken!
        ]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON
            { response in switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                
                let responseResult = JSON as! NSDictionary
                print(response.result)
                
                var jsonData: NSData?
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: responseResult, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
                    self.responseLabel?.text = NSString(data: jsonData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
                } catch _ {
                    jsonData = nil
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                }
        }
        
    }


}

