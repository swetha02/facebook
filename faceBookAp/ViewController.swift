//
//  ViewController.swift
//  faceBookAp
//
//  Created by swetha on 8/20/18.
//  Copyright © 2018 big nerd ranch. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FBSDKCoreKit
import FBSDKShareKit



class ViewController: UIViewController, LoginButtonDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate   {

    
    @IBOutlet weak var imgView: UIImageView!
    var imagePicker = UIImagePickerController()
    var mediaSelected = ""
    
    @IBOutlet weak var lblUsername: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
    
        self.lblUsername.text = ""
        imgView.image = nil
//        imgView.image = UIImage(named: "ccly.JPG")
        
        

        
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logout")
        self.lblUsername.text = ""
        imgView.image = nil
    }

    
    
    /*
     {
     id = 2039750969417669;
     name = "Swetha Kalali";
     picture =     {
         data =         {
             height = 320;
             "is_silhouette" = 0;
             url = "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=2039750969417669&height=250&width=250&ext=1537473809&hash=AeSxaamJQ0pcadiK";
             width = 320;
        };
     };
     } */
    
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("login")
 
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me?fields=name,picture.width(250).height(250)")) { httpResponse, result in
            switch result {
            case .success(let response):
                
                let dictionary = response.dictionaryValue!
                
                let name = dictionary["name"] as! String
                let picture = dictionary["picture"] as! [String:Any]
                let data = picture["data"] as! [String:Any]
                let urlString = data["url"] as! String
                
                let url = URL(string: urlString)
                
//                let dataImg = try? Data(contentsOf: url!)
//                self.imgView?.image = UIImage(data: dataImg!)

                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        self.imgView?.image = UIImage(data: data!)

                    }
                }

                
                
                
                self.lblUsername.text = "Welcome \(name)"
                print("\(response.dictionaryValue!)")
                
                
                
                
                print("Graph Request Succeeded: \(response)")
            case .failed(let error):
                print("Graph Request Failed: \(error)")
                
            }
        }
        connection.start()
       // showPhoto()

//getFacebookUserInfo()
    }

    
    func showPhoto() {
        
        let connection = GraphRequestConnection()
       
        connection.add(GraphRequest(graphPath: "/me/picture")) { httpResponse, result in
            switch result {
            case .success(let response):
                 print("Graph Request Succeeded: \(response)")
            case .failed(let error):
                print("Graph Request Failed: \(error)")
                
            }
        }
        connection.start()
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func buttonClick(_ sender: Any) {
        
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me")) { httpResponse, result in
            switch result {
            case .success(let response):
                let name = response.dictionaryValue!["name"] as! String
                 print("My name is \(name)")
                print("Graph Request Succeeded: \(response)")
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
        }
    
    
    func getFacebookUserInfo() {
        
        if FBSDKAccessToken.current() != nil  {
            //print permissions, such as public_profile
            print(FBSDKAccessToken.current().permissions)
//            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
//            graphRequest?.start(completionHandler: { (connection, result, error) -> Void in
//
                //                self.label.text = result.valueForKey("name") as? String
                //
                //                let FBid = result.valueForKey("id") as? String
                //
                if let url = URL(string: "https://graph.facebook.com/picture?type=large&return_ssl_resources=1") {
                    let data = try? Data(contentsOf: url)
                    
                    self.imgView.image = UIImage(data: (data)!)
                }
            }
        }

//    func showPhotoButton(){
//            let butn : UIButton = UIButton()
//            butn.backgroundColor = UIColor.brown
//            butn.setTitle("choose Photo", for: .normal)
//            butn.frame = CGRect(x: 100, y: 400, width: 100, height: 50)
//            butn.addTarget(self, action: Selector(("photoBtnClicked")), for: .touchUpInside)
//            self.view.addSubview(butn)
//
//            let label : UILabel = UILabel()
//            label.frame = CGRect(x: 50, y: 200, width: 50, height: 25)
//            label.text = "Photos Example"
//            label.textAlignment = .right
//            self.view.addSubview(label)
//
//    }
    

    
    
    @IBAction func butnClick(_ sender: Any) {
        
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            print("Photo capture")
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgView.image = info[UIImagePickerControllerOriginalImage]as? UIImage
//        imgView.backgroundColor = UIColor.clear
//        imgView.contentMode = UIViewContentMode.scaleAspectFit
        self.dismiss(animated: true, completion: nil)
        let photo :FBSDKSharePhoto = FBSDKSharePhoto()
        photo.image = imgView.image
        photo.isUserGenerated = true
        let content : FBSDKSharePhotoContent = FBSDKSharePhotoContent()
        content.photos = [photo]
        let shareButton = FBSDKShareButton()
//        shareButton.center = view.center
        shareButton.shareContent = content
        shareButton.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY + 30 )
        self.view.addSubview(shareButton)

    }

    

//func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//
//
//            let photo : FBSDKSharePhoto = FBSDKSharePhoto()
//            imgView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//            photo.isUserGenerated = true
//            let content : FBSDKSharePhotoContent = FBSDKSharePhotoContent()
//            content.photos = [photo]
//
//
//}
}
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSString:AnyObject]) {
//        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
//            return // No image selected.
//        }
//
//        let photo = Photo(image: image, userGenerated: true)
//        let content = PhotoShareContent(photos: [photo])
//        try ShareDialog.show(from: ViewController, content: content)
//    }













//
//
//        let photo : FBSDKSharePhoto = FBSDKSharePhoto()
//        photo.image = info[UIImagePickerControllerOriginalImage] as! UIImage
//        photo.userGenerated = true
//        let content : FBSDKSharePhotoContent = FBSDKSharePhotoContent()
//        content.photos = [photo]
//
//
//        let shareDialog = ShareDialog(content: myContent)
//        shareDialog.mode = .Native
//        shareDialog.failsOnInvalidData = true
//        shareDialog.completion = { result in
            // Handle share results


//        try shareDialog.show()






