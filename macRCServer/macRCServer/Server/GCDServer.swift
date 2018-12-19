import Foundation
import SwiftSocket

class Server {
    var date = Date.init()
    var formatter = DateFormatter.init()
    
    init() {
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        formatter.defaultDate = date
    }
    
    
    
    func echoService(client: TCPClient) {
        print("Newclient from:\(client.address)[\(client.port)]")
        
        let html = """
        <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
        <html>
        <head>
        <title>Hello</title>
        </head>
        <body>
        <h1>Hello World!</h1>
        <h2>Current time: \(formatter.string(from: date))</h2>
        <h2>Host name: \(Host.current().localizedName!)</h2>
        </body>
        </html>
        """
        
        let d = """
        HTTP/1.1 200 OK
        Date: \(Date.init())
        Server: assse
        Content-Length: \(html.count)
        Content-Type: text/html
        Connection: Closed
        
        \(html)
        """
        _ = client.send(string: d)
        client.close()
    }
    
    
    func testServer() {
        let server = TCPServer(address: "127.0.0.1", port: 65443)
        switch server.listen() {
        case .success:
            while true {
                if let client = server.accept() {
                    echoService(client: client)
                } else {
                    print("accept error")
                }
            }
        case .failure(let error):
            print(error)
        }
    }
}
