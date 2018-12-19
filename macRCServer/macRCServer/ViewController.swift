import Cocoa
import Foundation

class ViewController: NSViewController {
    var serv = Server.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonPressed(button: NSButton) {
        DispatchQueue.init(label: "Queue").async {
            self.serv.testServer()
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

