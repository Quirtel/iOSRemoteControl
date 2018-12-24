import Cocoa
import Foundation
import SwiftSocket

class ViewController: NSViewController {
    
    @IBOutlet weak var addressLabel: NSTextField!
    @IBOutlet weak var turnButton: NSButton!
    
    var currentServer: String?
    var serv: Server? = nil
    var serverQueue = DispatchQueue.init(label: "Server", qos: .background)
    
    var servers: [Server] = []
    
    var queue = DispatchQueue.init(label: "Queue")
    var isActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonPressed(button: NSButton) {
        DispatchQueue.main.async {
            if self.isActive {
                self.serv = nil
                self.addressLabel.stringValue = "Server is off"
                self.turnButton.title = "Turn on remote control"
                self.isActive = false
            }
            else {
                self.currentServer = self.resolveIPAddress()
                
                if let host = self.currentServer {
                    self.serv = Server.init(address: host)
                    
                    self.addressLabel.stringValue = "Success! IP: \(host)"
                    self.turnButton.title = "Turn off remote control"
                    self.isActive = true
                }
            }
        }
    }
    
    func resolveIPAddress() -> String? {
        for host in Host.current().addresses {
            servers.append(Server.init(address: host))
        }
        
        for serv in servers {
            let connectionCheck = TCPClient(address: serv.currentAddress, port: 65443)
            switch connectionCheck.connect(timeout: 5) {
            case .success:
                print(serv.currentAddress)
                connectionCheck.close()
                let addr = serv.currentAddress
                servers.removeAll()
                return addr
                
            case .failure(let error):
                print("\(error), host: \(serv.currentAddress)")
                break
            }
            connectionCheck.close()
        }
        
        servers.removeAll()
        return nil
    }
}

