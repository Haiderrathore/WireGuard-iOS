//
//  WireguardkitApp.swift
//  Wireguardkit
//
//  Created by Shahzain Ali on 27/08/2024.
//

//import SwiftUI
import UIKit
import NetworkExtension

class WireguardkitApp {
    
    func turnOnTunnel(completionHandler: @escaping (Bool) -> Void) {
        // We use loadAllFromPreferences to see if this app has already added a tunnel
        // to iOS Settings or (macOS Preferences)
        NETunnelProviderManager.loadAllFromPreferences { tunnelManagersInSettings, error in
            if let error = error {
                NSLog("Error (loadAllFromPreferences): \(error)")
                completionHandler(false)
                return
            }
            
            // If the app has already added a tunnel to Settings, we are going to modify that.
            // If not, we create a new instance and save that to Settings.
            // We will always have either 0 or 1 tunnel only in Settings for this app.
            let preExistingTunnelManager = tunnelManagersInSettings?.first
            let tunnelManager = preExistingTunnelManager ?? NETunnelProviderManager()
            
            // Configure the custom VPN protocol
            let protocolConfiguration = NETunnelProviderProtocol()
            
            // Set the tunnel extension's bundle id
            protocolConfiguration.providerBundleIdentifier = "com.rathore.solution-vpn-wireguard33.network-extension"
            
            // Set the server address as a non-nil string.
            // It would be good to provide the server's domain name or IP address.
            protocolConfiguration.serverAddress = "172.167.52.97"
            
            let wgQuickConfig = """
[Interface]
PrivateKey = cNm4SPv0+218WGa4URZaI1DCcBpdaGZ4vMYJnyFzp1g=
Address = 10.0.23.112/8
DNS = 9.9.9.9, 149.112.112.112

[Peer]
PublicKey = AvJedzn21NYlr3Nlvzi/wkt0/0SzZUEtlUBHko/u91s=
PresharedKey = TZqDC/w9iKjxvIGBOBMy/Y511n2cil9DsSnb8dOm4Cs=
Endpoint = 172.167.52.97:51820
AllowedIPs = 0.0.0.0/0,::0/0
"""
            
            protocolConfiguration.providerConfiguration = [
                "wgQuickConfig": wgQuickConfig
            ]
            
            tunnelManager.protocolConfiguration = protocolConfiguration
            tunnelManager.isEnabled = true
            
            // Save the tunnel to preferences.
            // This would modify the existing tunnel, or create a new one.
            tunnelManager.saveToPreferences { error in
                if let error = error {
                    NSLog("Error (saveToPreferences): \(error)")
                    completionHandler(false)
                    return
                }
                // Load it back so we have a valid usable instance.
                tunnelManager.loadFromPreferences { error in
                    if let error = error {
                        NSLog("Error (loadFromPreferences): \(error)")
                        completionHandler(false)
                        return
                    }
                    
                    // At this point, the tunnel is configured.
                    // Attempt to start the tunnel
                    do {
                        NSLog("Starting the tunnel")
                        guard let session = tunnelManager.connection as? NETunnelProviderSession else {
                            fatalError("tunnelManager.connection is invalid")
                        }
                        
                        try session.startTunnel()
                    } catch {
                        NSLog("Error (startTunnel): \(error)")
                        completionHandler(false)
                    }
                    completionHandler(true)
                }
            }
        }
    }
    
    func turnOffTunnel() {
        NETunnelProviderManager.loadAllFromPreferences { tunnelManagersInSettings, error in
            if let error = error {
                NSLog("Error (loadAllFromPreferences): \(error)")
                return
            }
            if let tunnelManager = tunnelManagersInSettings?.first {
                guard let session = tunnelManager.connection as? NETunnelProviderSession else {
                    fatalError("tunnelManager.connection is invalid")
                }
                switch session.status {
                case .connected, .connecting, .reasserting:
                    NSLog("Stopping the tunnel")
                    session.stopTunnel()
                default:
                    break
                }
            }
        }
    }
}
