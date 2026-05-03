# NOVAK B2 Action Catalog - network-evidence-v1 expansion library
# Boundary: read-only, no-admin, sanitized evidence only. No remediation, mutation, scanning, credentials, or target lists.

Set-StrictMode -Version 3.0

function New-NetworkEvidenceBasicEvidence {
    param(
        [Parameter(Mandatory)][string]$Slug,
        [Parameter(Mandatory)][string]$Profile
    )

    return [ordered]@{
        collection_completed = $true
        slug = $Slug
        profile = $Profile
        read_only = $true
        no_admin_required = $true
        remediation_performed = $false
        mutation_performed = $false
        raw_identifiers_recorded = $false
        network_scanning_performed = $false
        target_values_used = $false
    }
}

function Add-NetworkEvidenceCount {
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary]$Map,
        [AllowNull()][object]$Key
    )

    $safeKey = if ($null -eq $Key -or [string]::IsNullOrWhiteSpace([string]$Key)) { 'Unspecified' } else { [string]$Key }
    $safeKey = $safeKey -replace '[^A-Za-z0-9 _\-/]', '_'
    if (-not $Map.Contains($safeKey)) { $Map[$safeKey] = 0 }
    $Map[$safeKey] = [int]$Map[$safeKey] + 1
}

function Get-NetworkEvidenceEventCount {
    param(
        [Parameter(Mandatory)][string]$LogName,
        [int]$HoursBack = 24
    )

    $summary = [ordered]@{
        window_hours = $HoursBack
        log_available = $false
        event_count = 0
        warning_count = 0
        error_count = 0
        other_count = 0
    }

    $log = Get-WinEvent -ListLog $LogName -ErrorAction SilentlyContinue
    if ($null -eq $log) { return $summary }

    $summary['log_available'] = $true
    $events = @(Get-WinEvent -FilterHashtable @{ LogName = $LogName; StartTime = (Get-Date).AddHours(-[math]::Abs($HoursBack)) } -ErrorAction SilentlyContinue)

    foreach ($event in $events) {
        $summary['event_count'] = [int]$summary['event_count'] + 1
        switch ([int]$event.Level) {
            2 { $summary['error_count'] = [int]$summary['error_count'] + 1 }
            3 { $summary['warning_count'] = [int]$summary['warning_count'] + 1 }
            default { $summary['other_count'] = [int]$summary['other_count'] + 1 }
        }
    }

    return $summary
}

function Invoke-NetworkEvidenceExpansionAction {
    param(
        [Parameter(Mandatory)][string]$ActionId,
        [Parameter(Mandatory)][string]$Slug,
        [Parameter(Mandatory)][string]$Profile,
        [Parameter(Mandatory)][string]$Title
    )

    try {
        $evidence = New-NetworkEvidenceBasicEvidence -Slug $Slug -Profile $Profile
        $result = 'PASS'
        $message = "$Title collected using sanitized local evidence only."

        switch ($Profile) {
            'adapter' {
                if (-not (Get-Command -Name Get-NetAdapter -ErrorAction SilentlyContinue)) {
                    $evidence['collection_completed'] = $false
                    $evidence['command_available'] = $false
                    $result = 'WARN'
                    $message = "$Title could not run because the local adapter command is unavailable."
                    break
                }

                $items = @(Get-NetAdapter -ErrorAction SilentlyContinue)
                $statusCounts = [ordered]@{}
                $mediumCounts = [ordered]@{}
                $upCount = 0
                $virtualCount = 0

                foreach ($item in $items) {
                    Add-NetworkEvidenceCount -Map $statusCounts -Key $item.Status
                    if ($item.PSObject.Properties.Name -contains 'NdisPhysicalMedium') {
                        Add-NetworkEvidenceCount -Map $mediumCounts -Key $item.NdisPhysicalMedium
                    }
                    if ([string]$item.Status -eq 'Up') { $upCount++ }
                    if ($item.PSObject.Properties.Name -contains 'Virtual' -and [bool]$item.Virtual) { $virtualCount++ }
                }

                $evidence['adapter_count'] = $items.Count
                $evidence['up_adapter_count'] = $upCount
                $evidence['virtual_adapter_count'] = $virtualCount
                $evidence['status_counts'] = $statusCounts
                $evidence['media_category_counts'] = $mediumCounts
                if ($items.Count -eq 0) { $result = 'WARN' }
            }

            'ip' {
                if (-not (Get-Command -Name Get-NetIPConfiguration -ErrorAction SilentlyContinue)) {
                    $evidence['collection_completed'] = $false
                    $evidence['command_available'] = $false
                    $result = 'WARN'
                    $message = "$Title could not run because the local IP configuration command is unavailable."
                    break
                }

                $configs = @(Get-NetIPConfiguration -ErrorAction SilentlyContinue)
                $ipv4 = 0
                $ipv6 = 0
                $gateway = 0
                $dns = 0

                foreach ($config in $configs) {
                    if ($config.IPv4Address) { $ipv4++ }
                    if ($config.IPv6Address) { $ipv6++ }
                    if ($config.IPv4DefaultGateway -or $config.IPv6DefaultGateway) { $gateway++ }
                    if ($config.DNSServer -and $config.DNSServer.ServerAddresses -and @($config.DNSServer.ServerAddresses).Count -gt 0) { $dns++ }
                }

                $evidence['interface_configuration_count'] = $configs.Count
                $evidence['interfaces_with_ipv4_presence'] = $ipv4
                $evidence['interfaces_with_ipv6_presence'] = $ipv6
                $evidence['interfaces_with_gateway_presence'] = $gateway
                $evidence['interfaces_with_dns_presence'] = $dns
                if ($configs.Count -eq 0 -or $gateway -eq 0) { $result = 'WARN' }
            }

            'dhcp' {
                $svc = Get-Service -Name 'Dhcp' -ErrorAction SilentlyContinue
                $eventSummary = Get-NetworkEvidenceEventCount -LogName 'Microsoft-Windows-Dhcp-Client/Operational' -HoursBack 24

                $evidence['service_present'] = ($null -ne $svc)
                $evidence['service_status'] = if ($null -eq $svc) { 'NotFound' } else { [string]$svc.Status }
                $evidence['event_summary'] = $eventSummary
                if ($null -eq $svc -or [string]$svc.Status -ne 'Running') { $result = 'WARN' }
            }

            'dns' {
                $svc = Get-Service -Name 'Dnscache' -ErrorAction SilentlyContinue
                $clients = if (Get-Command -Name Get-DnsClient -ErrorAction SilentlyContinue) { @(Get-DnsClient -ErrorAction SilentlyContinue) } else { @() }
                $eventSummary = Get-NetworkEvidenceEventCount -LogName 'Microsoft-Windows-DNS-Client/Operational' -HoursBack 24

                $suffixPresent = 0
                foreach ($client in $clients) {
                    if (-not [string]::IsNullOrWhiteSpace([string]$client.ConnectionSpecificSuffix)) { $suffixPresent++ }
                }

                $evidence['service_present'] = ($null -ne $svc)
                $evidence['service_status'] = if ($null -eq $svc) { 'NotFound' } else { [string]$svc.Status }
                $evidence['dns_client_interface_count'] = $clients.Count
                $evidence['suffix_presence_count'] = $suffixPresent
                $evidence['event_summary'] = $eventSummary
                if ($null -eq $svc -or [string]$svc.Status -ne 'Running') { $result = 'WARN' }
            }

            'route' {
                $routes = if (Get-Command -Name Get-NetRoute -ErrorAction SilentlyContinue) { @(Get-NetRoute -ErrorAction SilentlyContinue) } else { @() }
                $interfaces = if (Get-Command -Name Get-NetIPInterface -ErrorAction SilentlyContinue) { @(Get-NetIPInterface -ErrorAction SilentlyContinue) } else { @() }
                $familyCounts = [ordered]@{}
                $protocolCounts = [ordered]@{}
                $defaultRouteCount = 0
                $autoMetricCount = 0

                foreach ($route in $routes) {
                    Add-NetworkEvidenceCount -Map $familyCounts -Key $route.AddressFamily
                    Add-NetworkEvidenceCount -Map $protocolCounts -Key $route.Protocol
                    if ([string]$route.DestinationPrefix -match '/0$') { $defaultRouteCount++ }
                }

                foreach ($interface in $interfaces) {
                    if ($interface.AutomaticMetric) { $autoMetricCount++ }
                }

                $evidence['route_count'] = $routes.Count
                $evidence['default_route_count'] = $defaultRouteCount
                $evidence['interface_count'] = $interfaces.Count
                $evidence['automatic_metric_count'] = $autoMetricCount
                $evidence['route_family_counts'] = $familyCounts
                $evidence['route_protocol_counts'] = $protocolCounts
                if ($routes.Count -eq 0 -or $defaultRouteCount -eq 0) { $result = 'WARN' }
            }

            'profile' {
                $profiles = if (Get-Command -Name Get-NetConnectionProfile -ErrorAction SilentlyContinue) { @(Get-NetConnectionProfile -ErrorAction SilentlyContinue) } else { @() }
                $svc = Get-Service -Name 'NlaSvc' -ErrorAction SilentlyContinue
                $categoryCounts = [ordered]@{}
                $ipv4Counts = [ordered]@{}
                $ipv6Counts = [ordered]@{}

                foreach ($profileItem in $profiles) {
                    Add-NetworkEvidenceCount -Map $categoryCounts -Key $profileItem.NetworkCategory
                    Add-NetworkEvidenceCount -Map $ipv4Counts -Key $profileItem.IPv4Connectivity
                    Add-NetworkEvidenceCount -Map $ipv6Counts -Key $profileItem.IPv6Connectivity
                }

                $evidence['profile_count'] = $profiles.Count
                $evidence['network_category_counts'] = $categoryCounts
                $evidence['ipv4_connectivity_counts'] = $ipv4Counts
                $evidence['ipv6_connectivity_counts'] = $ipv6Counts
                $evidence['nla_service_present'] = ($null -ne $svc)
                $evidence['nla_service_status'] = if ($null -eq $svc) { 'NotFound' } else { [string]$svc.Status }
                if ($profiles.Count -eq 0 -or $null -eq $svc -or [string]$svc.Status -ne 'Running') { $result = 'WARN' }
            }

            'firewall' {
                if (-not (Get-Command -Name Get-NetFirewallProfile -ErrorAction SilentlyContinue)) {
                    $evidence['collection_completed'] = $false
                    $evidence['command_available'] = $false
                    $result = 'WARN'
                    $message = "$Title could not run because the local firewall command is unavailable."
                    break
                }

                $profiles = @(Get-NetFirewallProfile -ErrorAction SilentlyContinue)
                $enabledCount = 0
                $inboundCounts = [ordered]@{}
                $outboundCounts = [ordered]@{}

                foreach ($profileItem in $profiles) {
                    if ($profileItem.Enabled) { $enabledCount++ }
                    Add-NetworkEvidenceCount -Map $inboundCounts -Key $profileItem.DefaultInboundAction
                    Add-NetworkEvidenceCount -Map $outboundCounts -Key $profileItem.DefaultOutboundAction
                }

                $evidence['profile_count'] = $profiles.Count
                $evidence['enabled_profile_count'] = $enabledCount
                $evidence['default_inbound_action_counts'] = $inboundCounts
                $evidence['default_outbound_action_counts'] = $outboundCounts
                $evidence['firewall_settings_modified'] = $false
                if ($profiles.Count -eq 0 -or $enabledCount -eq 0) { $result = 'WARN' }
            }

            'proxy' {
                $props = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
                $webClient = Get-Service -Name 'WebClient' -ErrorAction SilentlyContinue

                $proxyEnabled = $false
                $proxyServerConfigured = $false
                $autoConfigPresent = $false
                $autoDetectEnabled = $false

                if ($null -ne $props) {
                    if ($props.PSObject.Properties.Name -contains 'ProxyEnable') { $proxyEnabled = ([int]$props.ProxyEnable -ne 0) }
                    if ($props.PSObject.Properties.Name -contains 'ProxyServer') { $proxyServerConfigured = -not [string]::IsNullOrWhiteSpace([string]$props.ProxyServer) }
                    if ($props.PSObject.Properties.Name -contains 'AutoConfigURL') { $autoConfigPresent = -not [string]::IsNullOrWhiteSpace([string]$props.AutoConfigURL) }
                    if ($props.PSObject.Properties.Name -contains 'AutoDetect') { $autoDetectEnabled = ([int]$props.AutoDetect -ne 0) }
                }

                $evidence['settings_key_available'] = ($null -ne $props)
                $evidence['proxy_enabled'] = $proxyEnabled
                $evidence['proxy_server_config_present'] = $proxyServerConfigured
                $evidence['auto_config_present'] = $autoConfigPresent
                $evidence['auto_detect_enabled'] = $autoDetectEnabled
                $evidence['web_client_service_present'] = ($null -ne $webClient)
                $evidence['web_client_service_status'] = if ($null -eq $webClient) { 'NotFound' } else { [string]$webClient.Status }
            }

            'wifi' {
                $netshAvailable = $null -ne (Get-Command -Name netsh.exe -ErrorAction SilentlyContinue)
                $profileCount = 0
                $wifiAdapterCount = 0
                $signalCategory = 'Unknown'

                if ($netshAvailable) {
                    $profiles = @(netsh.exe wlan show profiles 2>$null)
                    foreach ($line in $profiles) {
                        if ([string]$line -match '^\s*(All User Profile|Current User Profile)\s*:') { $profileCount++ }
                    }

                    $interfaces = @(netsh.exe wlan show interfaces 2>$null)
                    foreach ($line in $interfaces) {
                        if ([string]$line -match '^\s*Signal\s*:\s*([0-9]+)%') {
                            $signal = [int]$Matches[1]
                            if ($signal -ge 80) { $signalCategory = 'High' }
                            elseif ($signal -ge 50) { $signalCategory = 'Medium' }
                            else { $signalCategory = 'Low' }
                        }
                    }
                }

                if (Get-Command -Name Get-NetAdapter -ErrorAction SilentlyContinue) {
                    $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue)
                    foreach ($adapter in $adapters) {
                        $medium = if ($adapter.PSObject.Properties.Name -contains 'NdisPhysicalMedium') { [string]$adapter.NdisPhysicalMedium } else { '' }
                        $description = if ($adapter.PSObject.Properties.Name -contains 'InterfaceDescription') { [string]$adapter.InterfaceDescription } else { '' }
                        if ($medium -match '802\.11|Wireless' -or $description -match 'Wi-Fi|Wireless|802\.11') { $wifiAdapterCount++ }
                    }
                }

                $evidence['netsh_available'] = $netshAvailable
                $evidence['wifi_profile_count'] = $profileCount
                $evidence['wifi_adapter_presence_count'] = $wifiAdapterCount
                $evidence['signal_category'] = $signalCategory
                $evidence['raw_ssids_recorded'] = $false
                if (-not $netshAvailable -or $wifiAdapterCount -eq 0) { $result = 'WARN' }
            }

            'vpn' {
                if (-not (Get-Command -Name Get-VpnConnection -ErrorAction SilentlyContinue)) {
                    $evidence['collection_completed'] = $true
                    $evidence['command_available'] = $false
                    $evidence['profile_count'] = 0
                    $result = 'WARN'
                    $message = "$Title completed with VPN command unavailable on this system."
                    break
                }

                $profiles = @(Get-VpnConnection -ErrorAction SilentlyContinue)
                $statusCounts = [ordered]@{}
                $splitTunnelingCount = 0

                foreach ($vpn in $profiles) {
                    Add-NetworkEvidenceCount -Map $statusCounts -Key $vpn.ConnectionStatus
                    if ($vpn.PSObject.Properties.Name -contains 'SplitTunneling' -and [bool]$vpn.SplitTunneling) { $splitTunnelingCount++ }
                }

                $evidence['profile_count'] = $profiles.Count
                $evidence['status_counts'] = $statusCounts
                $evidence['split_tunneling_enabled_count'] = $splitTunnelingCount
                $evidence['raw_profile_names_recorded'] = $false
            }

            'readiness' {
                $commands = @(
                    'Get-NetAdapter',
                    'Get-NetIPConfiguration',
                    'Get-DnsClient',
                    'Get-NetRoute',
                    'Get-NetIPInterface',
                    'Get-NetConnectionProfile',
                    'Get-NetFirewallProfile',
                    'Get-WinEvent',
                    'Get-Service',
                    'Get-VpnConnection',
                    'netsh.exe'
                )

                $present = 0
                $missing = New-Object System.Collections.Generic.List[string]

                foreach ($command in $commands) {
                    if (Get-Command -Name $command -ErrorAction SilentlyContinue) {
                        $present++
                    }
                    else {
                        $missing.Add($command)
                    }
                }

                $evidence['checked_command_count'] = $commands.Count
                $evidence['present_command_count'] = $present
                $evidence['missing_command_count'] = $missing.Count
                $evidence['missing_command_categories'] = @($missing.ToArray())
                if ($missing.Count -gt 0) { $result = 'WARN' }
            }

            default {
                $evidence['collection_completed'] = $false
                $evidence['unsupported_profile'] = $Profile
                $result = 'FAIL'
                $message = "$Title failed because the expansion profile is unsupported."
            }
        }

        Write-NetworkEvidenceResult -ActionId $ActionId -Result $result -Message $message -Evidence $evidence -EvidenceText $message
        if ($result -eq 'FAIL') { exit 1 }
        exit 0
    }
    catch {
        $safeError = $_.Exception.GetType().Name
        $evidence = [ordered]@{
            collection_completed = $false
            slug = $Slug
            profile = $Profile
            error_category = $safeError
            read_only = $true
            no_admin_required = $true
            remediation_performed = $false
            mutation_performed = $false
            raw_identifiers_recorded = $false
            network_scanning_performed = $false
            target_values_used = $false
        }

        Write-NetworkEvidenceResult -ActionId $ActionId -Result 'FAIL' -Message 'Expansion evidence collection failed before a sanitized result could be completed.' -Evidence $evidence -EvidenceText 'Expansion evidence collection failed before a sanitized result could be completed.'
        exit 1
    }
}