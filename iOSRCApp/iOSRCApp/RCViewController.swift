import UIKit
import SwiftSocket

class RCViewController: UIViewController {
    @IBOutlet weak var leftMouseButton: UIButton!
    @IBOutlet weak var rightMouseButton: UIButton!
    @IBOutlet weak var coordView: UIView!
    
    @IBOutlet weak var gestures: UIPanGestureRecognizer!
    var screenResolution: (width: Int, height: Int) = (0, 0)
    
    
    var currentRowInPicker = 0
    
    private var addr = String()
    var address: String {
        get {
            return addr
        }
        set(newValue) {
            addr = newValue
            connectAndActivate(addr: addr)
        }
    }
    
    var client: UDPClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func connectAndActivate(addr: String) {
        client = UDPClient(address: addr, port: 65443)
    }
    
    @IBAction func leftMouseButtonTapped(_ sender: Any) {
        _ = client?.send(string: "LMB")
    }
    
    @IBAction func rightMouseButtonTapped(_ sender: Any) {
        _ = client?.send(string: "RMB")
    }
    
    @IBAction func viewTapped(with: UIPanGestureRecognizer) {
        print("\(gestures.location(in: coordView).x) \(gestures.location(in: coordView).y)")
        print("\(gestures.translation(in: UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenResolution.width, height: screenResolution.height))))")
        let point = gestures.translation(in: UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenResolution.width, height: screenResolution.height)))
        _ = client?.send(string: "\(point.x) \(point.y)")
    }
}

extension RCViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 400
    }
}

extension RCViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentRowInPicker > row {
            _ = client?.send(string: "WH_UP")
        } else {
            _ = client?.send(string: "WH_DWN")
        }
        currentRowInPicker = row
    }
}


