//
//  WireGuardHandler.swift
//  Wireguard-Solution
//
//  Created by Haider on 30/12/2024.
//
import Foundation
import NetworkExtension

class WireGuardHandler {
    static let shared = WireGuardHandler()
    
    private init() {} // Singleton pattern to ensure a single instance is used.

    // MARK: - Save Configuration
    func saveWireGuardConfiguration(
        privateKey: String,
        address: String,
        dnsServers: [String],
        peerPublicKey: String,
        presharedKey: String,
        endpoint: String,
        allowedIPs: String,
        providerBundleIdentifier: String,
        completion: @escaping (Error?) -> Void
    ) {
        // Create the WireGuard configuration dictionary
        let tunnelConfig = [
            "Interface": [
                "PrivateKey": privateKey,
                "Address": address,
                "DNS": dnsServers.joined(separator: ", ")
            ],
            "Peer": [
                "PublicKey": peerPublicKey,
                "PresharedKey": presharedKey,
                "Endpoint": endpoint,
                "AllowedIPs": allowedIPs
            ]
        ]
        
//        // Encode the configuration dictionary to JSON
//        guard let jsonConfig = try? JSONSerialization.data(withJSONObject: tunnelConfig, options: []) else {
//            completion(NSError(domain: "WireGuardHandler", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode configuration"]))
//            return
//        }
//        
//        print("Json Config: \(String(decoding: jsonConfig, as: UTF8.self))")
        print("Json Config: \(tunnelConfig)")
        
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                completion(error)
                return
            }
            
            if let existingManager = managers?.first(where: {
                if let protocolConfig = $0.protocolConfiguration as? NETunnelProviderProtocol {
                    return protocolConfig.providerBundleIdentifier == providerBundleIdentifier
                }
                return false
            }) {
                if let tunnelProtocol = existingManager.protocolConfiguration as? NETunnelProviderProtocol {
                    tunnelProtocol.providerConfiguration = ["Config": tunnelConfig]
                    existingManager.protocolConfiguration = tunnelProtocol
                }
                existingManager.saveToPreferences { error in
                    completion(error)
                }
                return
            }
            
            // Setup a new configuration if none exists
            let tunnelProtocolConfiguration = NETunnelProviderProtocol()
            tunnelProtocolConfiguration.providerBundleIdentifier = providerBundleIdentifier
            tunnelProtocolConfiguration.serverAddress = "172.167.52.97"
            tunnelProtocolConfiguration.providerConfiguration = ["Config": tunnelConfig]
            
            let vpnManager = NETunnelProviderManager()
            vpnManager.protocolConfiguration = tunnelProtocolConfiguration
            vpnManager.localizedDescription = "WireGuard VPN"
            vpnManager.isEnabled = true
            
            vpnManager.saveToPreferences { error in
                completion(error)
            }
        }
    }

    // MARK: - Connect to VPN
    func connect(completion: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                completion(error)
                return
            }

            guard let vpnManager = managers?.first else {
                completion(NSError(domain: "WireGuardHandler", code: -1, userInfo: [NSLocalizedDescriptionKey: "No VPN configurations found"]))
                return
            }

            do {
                try vpnManager.connection.startVPNTunnel()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    // MARK: - Disconnect from VPN
    func disconnect(completion: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                completion(error)
                return
            }

            guard let vpnManager = managers?.first else {
                completion(NSError(domain: "WireGuardHandler", code: -1, userInfo: [NSLocalizedDescriptionKey: "No VPN configurations found"]))
                return
            }

            vpnManager.connection.stopVPNTunnel()
            completion(nil)
        }
    }
}
