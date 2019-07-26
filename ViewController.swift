//
//  ViewController.swift
//  worldfoto
//
//  Created by Denis Kravchenko on 08.08.2018.
//  Copyright © 2018 Denis Kravchenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        searchImage(text: "panda")
        textField.becomeFirstResponder()
        imageView.layer.masksToBounds = true
    }
    func convert(farm: Int, server: String, id: String, secret: String) -> URL? {
        let url = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_c.jpg")
        return url
    }
    
    func showLoader(show: Bool)  {
        DispatchQueue.main.async {
            if show{
                self.imageView.image = nil
                self.loader.startAnimating()
            } else {
                self.loader.stopAnimating()
            }
        }
    }
    
    func showAlert(text: String){
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        
        DispatchQueue.main.async{
            
            self.present(alert,animated: true)
        }
    }
    
    func searchImage(text:String) {
        
        showLoader(show: true)
        
        let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        let key = "&api_key=586ff04f3c463d0749c713a35bb5e64c"
        let farmattedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let textToSearch = "&text=\(farmattedText)"
        let format = "&format=json&nojsoncallback=1"
        
        let sort = "&sort=relevance"
        
        let searchUrl = base + key + format + textToSearch + sort
        
        let url = URL(string: searchUrl)!
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            guard let jsonData = data else {
                self.showAlert (text: "NO DATA")
                self.showLoader(show: false)
                return
            }
            guard let jsonAny = try? JSONSerialization.jsonObject(with: jsonData, options: []) else {
                self.showAlert(text:"no json")
                self.showLoader(show: false)
                return
            }
            guard let json = jsonAny as? [String: Any] else {
                self.showLoader(show: false)
                return
            }
            
            guard let photos = json["photos"] as? [String: Any] else {
                self.showLoader(show: false)
                return
            }
            guard let photosArray = photos["photo"] as? [Any] else {
                self.showLoader(show: false)
                return
            }
            guard photosArray.count > 0 else {
                self.showAlert(text:" no photos")
                self.showLoader(show: false)
                return
            }
            guard let firstPhoto = photosArray[0] as? [String: Any] else{
                self.showLoader(show: false)
                return
            }
            
            let farm = firstPhoto["farm"] as! Int
            let id = firstPhoto["id"] as! String
            let secret = firstPhoto["secret"] as! String
            let server = firstPhoto["server"] as! String
            
            let pictureUrl = self.convert(farm: farm, server: server, id: id, secret: secret)
            URLSession.shared.dataTask(with: pictureUrl!, completionHandler: { (data, _, _) in
                DispatchQueue.main.async{
                    self.imageView.image = UIImage(data: data!)
                }
                self.showLoader(show: false)
            }).resume()
            }.resume()
        
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchImage(text: textField.text!)
        
        return true
    }
}












