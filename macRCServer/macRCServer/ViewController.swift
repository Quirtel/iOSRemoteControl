import Cocoa
import Foundation
import SwiftSocket

class ViewController: NSViewController {
    
    @IBOutlet weak var addressLabel: NSTextField!
    @IBOutlet weak var turnButton: NSButton!
    
    var currentServer = String()
    var serv: Server? = nil
    var serverQueue = DispatchQueue.init(label: "Server", qos: .background)
    
    var serversGroup = OperationQueue.init()
    
    var queue = DispatchQueue.init(label: "Queue")
    var isActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonPressed(button: NSButton) {
        if isActive {
            queue.async {
                    self.serv = nil
            }
            
            DispatchQueue.main.async {
                self.addressLabel.stringValue = "Server is off"
                self.turnButton.title = "Turn on remote control"
            }
            isActive = false
        } else {
            for host in Host.current().addresses {
                let connectionCheck = TCPClient(address: host, port: 65443)
                
                    queue.async {
                        self.serv = Server.init(address: host, queue: self.serverQueue)
                    }
                
                switch connectionCheck.connect(timeout: 5) {
                case .success:
                    print(host)
                    
                    isActive = true
                    connectionCheck.close()
                    
                    DispatchQueue.main.async {
                        self.addressLabel.stringValue = "Success! IP: \(host)"
                        self.turnButton.title = "Turn off remote control"
                    }
                    
                    break
                case .failure(let error):
                    print("\(error), host: \(host)")
                    
                    queue.async {
                        self.serv = nil
                    }
                    
                    break
                }
                connectionCheck.close()
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

