import UIKit
import SwiftSocket

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var textFieldIP: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var labelResult: UILabel!
    
    
    let tapKeyboardOutside = UIGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
    func connectAndActivate(addr: String) {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
            self.labelResult.isHidden = false
            self.labelResult.text = "Connecting"
        }
        
        DispatchQueue.init(label: "Request").async {
            let client = TCPClient(address: addr, port: 65443)
            switch client.connect(timeout: 5) {
            case .success:
                
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.labelResult.isHidden = true
                }
                
                 DispatchQueue.main.async {
                    let newVC = self.storyboard?.instantiateViewController(withIdentifier: "RCViewController") as! RCViewController
                    self.navigationController?.pushViewController(newVC, animated: true)
                    newVC.address = addr
                    
                    while true {
                        if let screenResolutionResponse = client.read(30) {
                            let str = String.init(bytes: screenResolutionResponse, encoding: .utf8)
                            newVC.screenResolution.width = Int(str!.components(separatedBy: CharacterSet.init(charactersIn: " "))[0])!
                            newVC.screenResolution.height = Int(str!.components(separatedBy: CharacterSet.init(charactersIn: " "))[1])!
                        }
                    }
                }
                
                print("Success")
                
            case .failure(let error):
                print(error)
                
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.labelResult.isHidden = false
                    self.labelResult.text = "Connection failure"
                }
                
                break
            }
            client.close()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(tapKeyboardOutside)
        self.navigationItem.title = "MacRemote"
    }

}

extension MainViewController: UITextFieldDelegate {
    @objc func dismissKeyboard() {
        textFieldIP.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        connectAndActivate(addr: textField.text!)
    }
}

