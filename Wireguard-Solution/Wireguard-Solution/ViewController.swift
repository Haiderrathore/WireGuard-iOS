//
//  ViewController.swift
//  Wireguard-Solution
//
//  Created by Haider on 18/12/2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupWireGuardConfig()
    }
    
    func setupWireGuardConfig() {
        WireGuardHandler.shared.saveWireGuardConfiguration(
            privateKey: "AMgd2m4dEzyvIVBsxBDftO1mYY3wMoYkCFepb3l1Gkk=",
            address: "10.0.30.171/8",
            dnsServers: ["9.9.9.9", "149.112.112.112"],
            peerPublicKey: "fnX9Q5Rdz4rp8tv142uQiBsKTbWe884+nE/6/u7UkUQ=",
            presharedKey: "LZc67dV/eRz5UYiMyTmAKla2eGBgM/vhS0nCzQl20A=",
            endpoint: "172.166.218.240:51820",
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
        WireGuardHandler.shared.connect { error in
            if let error = error {
                print("Failed to connect: \(error.localizedDescription)")
            } else {
                print("VPN connected successfully!")
            }
        }
    }
    
    @IBAction func disconnectTapped(_ sender: Any) {
        WireGuardHandler.shared.disconnect { error in
            if let error = error {
                print("Failed to disconnect: \(error.localizedDescription)")
            } else {
                print("VPN disconnected successfully!")
            }
        }
    }
}
