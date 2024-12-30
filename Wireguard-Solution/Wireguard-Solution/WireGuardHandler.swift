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

        // Encode the configuration dictionary to JSON
        guard let jsonConfig = try? JSONSerialization.data(withJSONObject: tunnelConfig, options: []) else {
            completion(NSError(domain: "WireGuardHandler", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode configuration"]))
            return
        }
        print (String(data: jsonConfig, encoding: .utf8) ?? "")
//        print (jsonConfig)

        // Setup NETunnelProviderProtocol
        let tunnelProtocolConfiguration = NETunnelProviderProtocol()
        tunnelProtocolConfiguration.providerBundleIdentifier = providerBundleIdentifier
        tunnelProtocolConfiguration.serverAddress = "172.166.218.240"
        tunnelProtocolConfiguration.providerConfiguration = ["Config": jsonConfig]

        // Setup NETunnelProviderManager
        let vpnManager = NETunnelProviderManager()
        vpnManager.protocolConfiguration = tunnelProtocolConfiguration
        vpnManager.localizedDescription = "WireGuards VPN"
        vpnManager.isOnDemandEnabled = true
        vpnManager.isEnabled = true

        // Save configuration to preferences
        vpnManager.saveToPreferences { error in
            completion(error)
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
