//
//  ViewController.swift
//  Wireguard-Solution
//
//  Created by Haider on 18/12/2024.
//

import UIKit

class ViewController: UIViewController {
    var wgKit = WireguardkitApp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        wgKit = WireguardkitApp()

//        setupWireGuardConfig()
        NSLog("WireGuard Tunnel V D L")

    }
    
    func setupWireGuardConfig() {
        WireGuardHandler.shared.saveWireGuardConfiguration(
            privateKey: "6NINWJnfcbMXFnka2EQ4fWi5mOgGYjEjaWBff64yiXI=",
            address: "10.0.0.74/8",
            dnsServers: ["9.9.9.9", "149.112.112.112"],
            peerPublicKey: "AvJedzn21NYlr3Nlvzi/wkt0/0SzZUEtlUBHko/u91s=",
            presharedKey: "YOWZDdPfE6N4Pu2NFOqf4GHntA5gBZZsYLPCD4ee2I4=",
            endpoint: "172.167.52.97:51820",
            allowedIPs: "0.0.0.0/0, ::/0",
            providerBundleIdentifier: "com.rathore.solution-vpn-wireguard33.network-extension"
        ) { error in
            if let error = error {
                print("Failed to save configuration: \(error.localizedDescription)")
            } else {
                print("WireGuard configuration saved successfully!")
            }
        }
    }
    
    @IBAction func connectTapped(_ sender: Any) {
//        WireGuardHandler.shared.connect { error in
//            if let error = error {
//                print("Failed to connect: \(error.localizedDescription)")
//            } else {
//                print("VPN connected successfully!")
//            }
//        }
        wgKit.turnOnTunnel { isSuccess in
            print("Tunnel turned on: \(isSuccess)")
        }
    }
    
    @IBAction func disconnectTapped(_ sender: Any) {
//        WireGuardHandler.shared.disconnect { error in
//            if let error = error {
//                print("Failed to disconnect: \(error.localizedDescription)")
//            } else {
//                print("VPN disconnected successfully!")
//            }
//        }
        
        wgKit.turnOffTunnel()
    }
}
