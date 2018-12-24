import Foundation
import SwiftSocket

class Server {
    var testServer: TCPServer?
    var server: UDPServer?
    var isActive = false
    var currentAddress = String()
    var serverQueue = DispatchQueue.init(label: "Server")
    
    var eventsQueue = DispatchQueue.init(label: "Events")
    
    var x = CGFloat.init()
    var y = CGFloat.init()
    
    var prev_pos = (x: CGFloat.init(0), y: CGFloat.init(0))
    
    init(address: String) {
        currentAddress = address
        
        testServer = TCPServer(address: address, port: 65443)
        server = UDPServer(address: address, port: 65443)
        
        serverQueue.async {
            self.startServer()
        }
        
        print("server on \(currentAddress) created")
    }
    
    deinit {
        self.server?.close()
        self.testServer?.close()
        
        print("server on \(currentAddress) closed")
    }
    
    func startReceiver() {
        print("Receiver started")
        
        serverQueue.async {
            while true {
                let result = self.server?.recv(20).0 ?? [0]
                if result.count > 1 {
                    print(String.init(bytes: result, encoding: .utf8) as Any)
                }
                
                let str = String.init(bytes: result, encoding: .utf8)
                if str == "LMB" {
                    self.eventsQueue.async {
                        let click_down = CGEvent.init(mouseEventSource: nil, mouseType: .leftMouseDown ,
                                               mouseCursorPosition: CGPoint.init(x: NSEvent.mouseLocation.x, y: 1080 - NSEvent.mouseLocation.y), mouseButton: .left)
                        
                        let click_up = CGEvent.init(mouseEventSource: nil, mouseType: .leftMouseUp ,
                                               mouseCursorPosition: CGPoint.init(x: NSEvent.mouseLocation.x, y: 1080 - NSEvent.mouseLocation.y), mouseButton: .left)
                        
                        print("x = \(NSEvent.mouseLocation.x), y = \(NSEvent.mouseLocation.y)")
                        click_down?.post(tap: .cghidEventTap)
                        click_up?.post(tap: .cghidEventTap)
                    }
                } else if str == "RMB" {
                    self.eventsQueue.async {
                        let click_down = CGEvent.init(mouseEventSource: nil, mouseType: .rightMouseDown ,
                                                      mouseCursorPosition:
                            CGPoint.init(x: NSEvent.mouseLocation.x, y: 1080 - NSEvent.mouseLocation.y), mouseButton: .right)
                        
                        let click_up = CGEvent.init(mouseEventSource: nil, mouseType: .rightMouseUp ,
                                                    mouseCursorPosition:
                            CGPoint.init(x: NSEvent.mouseLocation.x, y: 1080 - NSEvent.mouseLocation.y), mouseButton: .right)
                        
                        print("x = \(NSEvent.mouseLocation.x), y = \(NSEvent.mouseLocation.y)")
                        click_down?.post(tap: .cghidEventTap)
                        click_up?.post(tap: .cghidEventTap)
                    }
                } else if str == "WH_DWN" {
                    let click_down = CGEvent.init(scrollWheelEvent2Source: nil, units: .line, wheelCount: 3, wheel1: -3, wheel2: 0, wheel3: 0)
                    click_down?.post(tap: .cghidEventTap)
                } else if str == "WH_UP" {
                    let click_down = CGEvent.init(scrollWheelEvent2Source: nil, units: .line, wheelCount: 3, wheel1: 3, wheel2: 0, wheel3: 0)
                    click_down?.post(tap: .cghidEventTap)
                } else {
                    let pos_x = CGFloat.init(Double(str!.components(separatedBy: CharacterSet.init(charactersIn: " "))[0])!)
                    let pos_y = CGFloat.init(Double(str!.components(separatedBy: CharacterSet.init(charactersIn: " "))[1])!)
                    
                    print("\(pos_x) \(pos_y)")
                    
                    let mouse_move = CGEvent.init(mouseEventSource: nil, mouseType: .mouseMoved,
                                                  mouseCursorPosition:
                        CGPoint.init(x: NSEvent.mouseLocation.x, y: 1080 - NSEvent.mouseLocation.y), mouseButton: .left)
                    
                   
                        mouse_move?.location.x = NSEvent.mouseLocation.x + (pos_x * 0.094)
                    
                        mouse_move?.location.y = 1080 - NSEvent.mouseLocation.y + (pos_y * 0.094)
                    
                    self.prev_pos.x = pos_x
                    self.prev_pos.y = pos_y

                    mouse_move?.post(tap: .cghidEventTap)
                }
            }
        }
    }
    
    func startServer() {
        switch self.testServer!.listen() {
        case .success:
            self.isActive = true
            while true {
                if let client = self.testServer!.accept() {
                    print("Newclient from:\(client.address)[\(client.port)]")
                    if let screen = NSScreen.main {
                        let rect = screen.frame
                        let height = rect.size.height
                        let width = rect.size.width
                        _ = client.send(string: "\(width) \(height)")
                    }
                    
                    self.startReceiver()
                } else {
                    print("accept error")
                }
            }
        case .failure(let error):
            print(error)
        }
    }
}
