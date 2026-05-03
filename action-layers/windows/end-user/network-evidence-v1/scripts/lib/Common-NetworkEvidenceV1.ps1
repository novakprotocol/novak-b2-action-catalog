# NOVAK B2 Action Catalog - network-evidence-v1 common library
# Boundary: read-only, no-admin, sanitized evidence only. No remediation, mutation, scanning, credentials, or target lists.

Set-StrictMode -Version 3.0

$script:NetworkEvidenceLayerId = 'network-evidence-v1'

function Get-NetworkEvidenceTimestampUtc {
    return (Get-Date).ToUniversalTime().ToString('o')
}

function Get-NetworkEvidenceRoot {
    $documents = [Environment]::GetFolderPath('MyDocuments')
    if ([string]::IsNullOrWhiteSpace($documents)) {
        $documents = Join-Path $env:USERPROFILE 'Documents'
    }
    return (Join-Path $documents 'NOVAK-B2-Windows-SelfCheck')
}

function New-NetworkEvidenceOutputDirectory {
    param([Parameter(Mandatory)][string]$ActionId)

    $root = Get-NetworkEvidenceRoot
    $layer = Join-Path $root $script:NetworkEvidenceLayerId
    $safeActionId = ($ActionId -replace '[^A-Z0-9_ -]', '_')
    $dir = Join-Path $layer $safeActionId

    if (-not (Test-Path -LiteralPath $dir)) {
        $null = New-Item -Path $dir -ItemType Directory -Force
    }

    return $dir
}

function ConvertTo-SafeEvidenceText {
    param([AllowNull()][string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return 'No additional sanitized evidence text.'
    }

    $singleLine = ($Text -replace "(`r`n|`n|`r)", ' | ')
    if ($singleLine.Length -gt 1800) {
        return ($singleLine.Substring(0, 1800) + '...')
    }

    return $singleLine
}

function New-EmptyCountMap {
    return [ordered]@{}
}

function Add-CountToMap {
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary]$Map,
        [AllowNull()][object]$Key
    )

    $safeKey = if ($null -eq $Key -or [string]::IsNullOrWhiteSpace([string]$Key)) { 'Unspecified' } else { [string]$Key }
    $safeKey = $safeKey -replace '[^A-Za-z0-9 _\-/]', '_'

    if (-not $Map.Contains($safeKey)) {
        $Map[$safeKey] = 0
    }

    $Map[$safeKey] = [int]$Map[$safeKey] + 1
}

function Get-CommandPresenceSummary {
    param([Parameter(Mandatory)][string[]]$CommandNames)

    $missing = New-Object System.Collections.Generic.List[string]
    $presentCount = 0

    foreach ($name in $CommandNames) {
        if (Get-Command -Name $name -ErrorAction SilentlyContinue) {
            $presentCount++
        }
        else {
            $missing.Add($name)
        }
    }

    return [ordered]@{
        checked_count = $CommandNames.Count
        present_count = $presentCount
        missing_count = $missing.Count
        missing_command_categories = @($missing.ToArray())
    }
}

function Get-ServiceStateSummary {
    param([Parameter(Mandatory)][string]$ServiceName)

    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($null -eq $svc) {
        return [ordered]@{
            service_present = $false
            status = 'NotFound'
            start_type = 'Unknown'
        }
    }

    $startType = 'Unknown'
    try {
        $escaped = $ServiceName.Replace("'", "''")
        $cim = Get-CimInstance -ClassName Win32_Service -Filter "Name='$escaped'" -ErrorAction Stop
        if ($null -ne $cim) { $startType = [string]$cim.StartMode }
    }
    catch {
        $startType = 'Unavailable'
    }

    return [ordered]@{
        service_present = $true
        status = [string]$svc.Status
        start_type = $startType
    }
}

function Get-EventCountSummary {
    param(
        [Parameter(Mandatory)][string]$LogName,
        [int]$HoursBack = 24
    )

    $summary = [ordered]@{
        window_hours = $HoursBack
        log_available = $false
        event_count = 0
        information_count = 0
        warning_count = 0
        error_count = 0
        other_count = 0
        collection_status = 'NotStarted'
    }

    $logInfo = Get-WinEvent -ListLog $LogName -ErrorAction SilentlyContinue
    if ($null -eq $logInfo) {
        $summary['collection_status'] = 'LogUnavailable'
        return $summary
    }

    $summary['log_available'] = $true
    $startTime = (Get-Date).AddHours(-[math]::Abs($HoursBack))
    $events = @(Get-WinEvent -FilterHashtable @{ LogName = $LogName; StartTime = $startTime } -ErrorAction SilentlyContinue)

    foreach ($event in $events) {
        $summary['event_count'] = [int]$summary['event_count'] + 1
        switch ([int]$event.Level) {
            2 { $summary['error_count'] = [int]$summary['error_count'] + 1 }
            3 { $summary['warning_count'] = [int]$summary['warning_count'] + 1 }
            4 { $summary['information_count'] = [int]$summary['information_count'] + 1 }
            default { $summary['other_count'] = [int]$summary['other_count'] + 1 }
        }
    }

    $summary['collection_status'] = 'Completed'
    return $summary
}

function Write-NetworkEvidenceResult {
    param(
        [Parameter(Mandatory)][string]$ActionId,
        [Parameter(Mandatory)][ValidateSet('PASS','WARN','FAIL')][string]$Result,
        [Parameter(Mandatory)][string]$Message,
        [Parameter(Mandatory)]$Evidence,
        [AllowNull()][string]$EvidenceText
    )

    $safeEvidenceText = ConvertTo-SafeEvidenceText -Text $EvidenceText
    $timestamp = Get-NetworkEvidenceTimestampUtc

    $payload = [ordered]@{
        layer_id = $script:NetworkEvidenceLayerId
        action_id = $ActionId
        result = $Result
        message = $Message
        generated_utc = $timestamp
        sanitization = 'Evidence intentionally uses counts, booleans, categories, and generic labels only.'
        evidence = $Evidence
    }

    $outputDirectory = New-NetworkEvidenceOutputDirectory -ActionId $ActionId
    $resultJsonPath = Join-Path $outputDirectory 'result.json'
    $resultTextPath = Join-Path $outputDirectory 'result.txt'

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resultJsonPath, ($payload | ConvertTo-Json -Depth 12), $encoding)

    $textPayload = @(
        "ACTION_ID=$ActionId"
        "RESULT=$Result"
        "MESSAGE=$Message"
        "GENERATED_UTC=$timestamp"
        "SANITIZATION=Counts, booleans, categories, and generic labels only."
        "EVIDENCE_TEXT=$safeEvidenceText"
    ) -join [Environment]::NewLine

    [System.IO.File]::WriteAllText($resultTextPath, $textPayload, $encoding)

    $compactJson = $payload | ConvertTo-Json -Depth 12 -Compress

    Write-Output "ACTION_ID=$ActionId"
    Write-Output "RESULT=$Result"
    Write-Output "MESSAGE=$Message"
    Write-Output "EVIDENCE_JSON=$compactJson"
    Write-Output "EVIDENCE_TEXT=$safeEvidenceText"
}

function Invoke-NetworkEvidenceAction {
    param(
        [Parameter(Mandatory)][string]$ActionId,
        [Parameter(Mandatory)][string]$Slug
    )

    try {
        switch ($Slug) {
            'network-package-readiness' {
                $commands = @('Get-NetAdapter','Get-NetIPConfiguration','Get-DnsClient','Get-NetRoute','Get-NetIPInterface','Get-NetConnectionProfile','Get-Service','Get-NetFirewallProfile','Get-WinEvent')
                $presence = Get-CommandPresenceSummary -CommandNames $commands
                $resultValue = if ([int]$presence['missing_count'] -eq 0) { 'PASS' } else { 'WARN' }
                $message = if ($resultValue -eq 'PASS') { 'Network evidence package readiness checks passed.' } else { 'Network evidence package readiness has limited command availability; remaining checks will report sanitized warnings where needed.' }
                $evidence = [ordered]@{ collection_completed = $true; windows_context_expected = $true; read_only = $true; no_admin_required = $true; remediation_performed = $false; mutation_performed = $false; command_presence = $presence }
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-adapter-summary' {
                if (-not (Get-Command -Name Get-NetAdapter -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'Adapter summary command is unavailable on this system.' -Evidence $evidence -EvidenceText 'Adapter summary command is unavailable on this system.'
                    return
                }

                $adapters = @(Get-NetAdapter -ErrorAction Stop)
                $statusCounts = New-EmptyCountMap
                $virtualCount = 0
                $hardwareInterfaceCount = 0

                foreach ($adapter in $adapters) {
                    Add-CountToMap -Map $statusCounts -Key $adapter.Status
                    if ($adapter.PSObject.Properties.Name -contains 'Virtual' -and [bool]$adapter.Virtual) { $virtualCount++ }
                    if ($adapter.PSObject.Properties.Name -contains 'HardwareInterface' -and [bool]$adapter.HardwareInterface) { $hardwareInterfaceCount++ }
                }

                $upCount = @($adapters | Where-Object { [string]$_.Status -eq 'Up' }).Count
                $evidence = [ordered]@{ collection_completed = $true; adapter_count = $adapters.Count; up_adapter_count = $upCount; non_up_adapter_count = ($adapters.Count - $upCount); virtual_adapter_count = $virtualCount; hardware_interface_adapter_count = $hardwareInterfaceCount; status_counts = $statusCounts }
                $resultValue = if ($adapters.Count -gt 0) { 'PASS' } else { 'WARN' }
                $message = if ($adapters.Count -gt 0) { 'Adapter summary collected using sanitized counts.' } else { 'No network adapters were reported by the local command.' }
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-connected-adapter-summary' {
                if (-not (Get-Command -Name Get-NetAdapter -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'Connected adapter command is unavailable on this system.' -Evidence $evidence -EvidenceText 'Connected adapter command is unavailable on this system.'
                    return
                }

                $adapters = @(Get-NetAdapter -ErrorAction Stop)
                $connected = @($adapters | Where-Object { [string]$_.Status -eq 'Up' })
                $statusCounts = New-EmptyCountMap
                $hardwareConnectedCount = 0

                foreach ($adapter in $adapters) { Add-CountToMap -Map $statusCounts -Key $adapter.Status }
                foreach ($adapter in $connected) {
                    if ($adapter.PSObject.Properties.Name -contains 'HardwareInterface' -and [bool]$adapter.HardwareInterface) { $hardwareConnectedCount++ }
                }

                $evidence = [ordered]@{ collection_completed = $true; adapter_count = $adapters.Count; connected_adapter_count = $connected.Count; disconnected_or_other_adapter_count = ($adapters.Count - $connected.Count); hardware_connected_adapter_count = $hardwareConnectedCount; status_counts = $statusCounts }
                $resultValue = if ($connected.Count -gt 0) { 'PASS' } else { 'WARN' }
                $message = if ($connected.Count -gt 0) { 'Connected adapter summary collected using sanitized counts.' } else { 'No connected adapters were reported by the local command.' }
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-ip-configuration-summary' {
                if (-not (Get-Command -Name Get-NetIPConfiguration -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'IP configuration command is unavailable on this system.' -Evidence $evidence -EvidenceText 'IP configuration command is unavailable on this system.'
                    return
                }

                $configs = @(Get-NetIPConfiguration -ErrorAction Stop)
                $withIPv4 = 0
                $withIPv6 = 0
                $withAnyGateway = 0
                $withDnsServers = 0

                foreach ($config in $configs) {
                    if ($config.IPv4Address) { $withIPv4++ }
                    if ($config.IPv6Address) { $withIPv6++ }
                    if ($config.IPv4DefaultGateway -or $config.IPv6DefaultGateway) { $withAnyGateway++ }
                    $dnsCount = 0
                    if ($config.DNSServer -and $config.DNSServer.ServerAddresses) { $dnsCount = @($config.DNSServer.ServerAddresses).Count }
                    if ($dnsCount -gt 0) { $withDnsServers++ }
                }

                $evidence = [ordered]@{ collection_completed = $true; interface_configuration_count = $configs.Count; interfaces_with_ipv4_presence = $withIPv4; interfaces_with_ipv6_presence = $withIPv6; interfaces_with_default_gateway_presence = $withAnyGateway; interfaces_with_dns_server_presence = $withDnsServers; raw_addresses_recorded = $false }
                $resultValue = if ($configs.Count -gt 0) { 'PASS' } else { 'WARN' }
                $message = 'IP configuration summary collected without recording addresses, suffixes, or names.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-dns-client-summary' {
                if (-not (Get-Command -Name Get-DnsClient -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'DNS client command is unavailable on this system.' -Evidence $evidence -EvidenceText 'DNS client command is unavailable on this system.'
                    return
                }

                $clients = @(Get-DnsClient -ErrorAction Stop)
                $suffixPresentCount = 0
                $registerEnabledCount = 0
                $suffixRegistrationEnabledCount = 0

                foreach ($client in $clients) {
                    if (-not [string]::IsNullOrWhiteSpace([string]$client.ConnectionSpecificSuffix)) { $suffixPresentCount++ }
                    if ($client.PSObject.Properties.Name -contains 'RegisterThisConnectionsAddress' -and [bool]$client.RegisterThisConnectionsAddress) { $registerEnabledCount++ }
                    if ($client.PSObject.Properties.Name -contains 'UseSuffixWhenRegistering' -and [bool]$client.UseSuffixWhenRegistering) { $suffixRegistrationEnabledCount++ }
                }

                $evidence = [ordered]@{ collection_completed = $true; dns_client_interface_count = $clients.Count; connection_specific_suffix_present_count = $suffixPresentCount; register_address_enabled_count = $registerEnabledCount; suffix_registration_enabled_count = $suffixRegistrationEnabledCount; raw_suffixes_recorded = $false; raw_server_values_recorded = $false }
                $resultValue = if ($clients.Count -gt 0) { 'PASS' } else { 'WARN' }
                $message = 'DNS client summary collected using sanitized settings presence only.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-default-gateway-summary' {
                if (-not (Get-Command -Name Get-NetIPConfiguration -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'Default gateway summary command is unavailable on this system.' -Evidence $evidence -EvidenceText 'Default gateway summary command is unavailable on this system.'
                    return
                }

                $configs = @(Get-NetIPConfiguration -ErrorAction Stop)
                $withIPv4Gateway = 0
                $withIPv6Gateway = 0
                $withAnyGateway = 0

                foreach ($config in $configs) {
                    $hasIPv4Gateway = $null -ne $config.IPv4DefaultGateway
                    $hasIPv6Gateway = $null -ne $config.IPv6DefaultGateway
                    if ($hasIPv4Gateway) { $withIPv4Gateway++ }
                    if ($hasIPv6Gateway) { $withIPv6Gateway++ }
                    if ($hasIPv4Gateway -or $hasIPv6Gateway) { $withAnyGateway++ }
                }

                $evidence = [ordered]@{ collection_completed = $true; interface_configuration_count = $configs.Count; interfaces_with_ipv4_gateway_presence = $withIPv4Gateway; interfaces_with_ipv6_gateway_presence = $withIPv6Gateway; interfaces_with_any_gateway_presence = $withAnyGateway; raw_gateway_values_recorded = $false }
                $resultValue = if ($withAnyGateway -gt 0) { 'PASS' } else { 'WARN' }
                $message = if ($withAnyGateway -gt 0) { 'Default gateway presence summary collected without gateway values.' } else { 'No default gateway presence was reported by the local command.' }
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-route-summary' {
                if (-not (Get-Command -Name Get-NetRoute -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'Route summary command is unavailable on this system.' -Evidence $evidence -EvidenceText 'Route summary command is unavailable on this system.'
                    return
                }

                $routes = @(Get-NetRoute -ErrorAction Stop)
                $familyCounts = New-EmptyCountMap
                $protocolCounts = New-EmptyCountMap
                $defaultRouteCount = 0

                foreach ($route in $routes) {
                    Add-CountToMap -Map $familyCounts -Key $route.AddressFamily
                    Add-CountToMap -Map $protocolCounts -Key $route.Protocol
                    $prefix = [string]$route.DestinationPrefix
                    if (-not [string]::IsNullOrWhiteSpace($prefix) -and $prefix.EndsWith('/0')) { $defaultRouteCount++ }
                }

                $evidence = [ordered]@{ collection_completed = $true; route_count = $routes.Count; default_route_presence_count = $defaultRouteCount; address_family_counts = $familyCounts; protocol_counts = $protocolCounts; raw_destinations_recorded = $false; raw_next_hops_recorded = $false }
                $resultValue = if ($routes.Count -gt 0) { 'PASS' } else { 'WARN' }
                $message = 'Route summary collected using counts and generic categories only.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-interface-metric-summary' {
                if (-not (Get-Command -Name Get-NetIPInterface -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'Interface metric command is unavailable on this system.' -Evidence $evidence -EvidenceText 'Interface metric command is unavailable on this system.'
                    return
                }

                $interfaces = @(Get-NetIPInterface -ErrorAction Stop)
                $automaticMetricCount = 0
                $manualMetricCount = 0
                $metricValues = New-Object System.Collections.Generic.List[int]
                $familyCounts = New-EmptyCountMap

                foreach ($interface in $interfaces) {
                    Add-CountToMap -Map $familyCounts -Key $interface.AddressFamily
                    if ($interface.AutomaticMetric) { $automaticMetricCount++ } else { $manualMetricCount++ }
                    if ($null -ne $interface.InterfaceMetric) { $metricValues.Add([int]$interface.InterfaceMetric) }
                }

                $minMetric = if ($metricValues.Count -gt 0) { ($metricValues | Measure-Object -Minimum).Minimum } else { $null }
                $maxMetric = if ($metricValues.Count -gt 0) { ($metricValues | Measure-Object -Maximum).Maximum } else { $null }
                $evidence = [ordered]@{ collection_completed = $true; interface_count = $interfaces.Count; automatic_metric_count = $automaticMetricCount; manual_metric_count = $manualMetricCount; minimum_metric_observed = $minMetric; maximum_metric_observed = $maxMetric; address_family_counts = $familyCounts; raw_interface_names_recorded = $false }
                $resultValue = if ($interfaces.Count -gt 0) { 'PASS' } else { 'WARN' }
                $message = 'Interface metric summary collected without interface names.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-profile-summary' {
                if (-not (Get-Command -Name Get-NetConnectionProfile -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'Network profile command is unavailable on this system.' -Evidence $evidence -EvidenceText 'Network profile command is unavailable on this system.'
                    return
                }

                $profiles = @(Get-NetConnectionProfile -ErrorAction Stop)
                $categoryCounts = New-EmptyCountMap
                $ipv4ConnectivityCounts = New-EmptyCountMap
                $ipv6ConnectivityCounts = New-EmptyCountMap

                foreach ($profile in $profiles) {
                    Add-CountToMap -Map $categoryCounts -Key $profile.NetworkCategory
                    Add-CountToMap -Map $ipv4ConnectivityCounts -Key $profile.IPv4Connectivity
                    Add-CountToMap -Map $ipv6ConnectivityCounts -Key $profile.IPv6Connectivity
                }

                $evidence = [ordered]@{ collection_completed = $true; profile_count = $profiles.Count; network_category_counts = $categoryCounts; ipv4_connectivity_counts = $ipv4ConnectivityCounts; ipv6_connectivity_counts = $ipv6ConnectivityCounts; raw_profile_names_recorded = $false }
                $resultValue = if ($profiles.Count -gt 0) { 'PASS' } else { 'WARN' }
                $message = 'Network profile summary collected without profile names.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-proxy-summary' {
                $internetSettingsPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
                $props = Get-ItemProperty -Path $internetSettingsPath -ErrorAction SilentlyContinue

                $proxyEnabled = $false
                $proxyServerConfigured = $false
                $autoConfigConfigured = $false
                $autoDetectConfigured = $false

                if ($null -ne $props) {
                    if ($props.PSObject.Properties.Name -contains 'ProxyEnable') { $proxyEnabled = ([int]$props.ProxyEnable -ne 0) }
                    if ($props.PSObject.Properties.Name -contains 'ProxyServer') { $proxyServerConfigured = -not [string]::IsNullOrWhiteSpace([string]$props.ProxyServer) }
                    if ($props.PSObject.Properties.Name -contains 'AutoConfigURL') { $autoConfigConfigured = -not [string]::IsNullOrWhiteSpace([string]$props.AutoConfigURL) }
                    if ($props.PSObject.Properties.Name -contains 'AutoDetect') { $autoDetectConfigured = ([int]$props.AutoDetect -ne 0) }
                }

                $evidence = [ordered]@{ collection_completed = $true; settings_key_available = ($null -ne $props); proxy_enabled = $proxyEnabled; proxy_server_config_present = $proxyServerConfigured; auto_config_present = $autoConfigConfigured; auto_detect_enabled = $autoDetectConfigured; raw_proxy_values_recorded = $false }
                $message = 'Proxy summary collected using booleans only; proxy targets were not recorded.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result 'PASS' -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-vpn-profile-presence-summary' {
                if (-not (Get-Command -Name Get-VpnConnection -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false; profile_count = 0 }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'VPN profile command is unavailable on this system.' -Evidence $evidence -EvidenceText 'VPN profile command is unavailable on this system.'
                    return
                }

                $profiles = @(Get-VpnConnection -ErrorAction SilentlyContinue)
                $statusCounts = New-EmptyCountMap
                $splitTunnelingEnabledCount = 0

                foreach ($profile in $profiles) {
                    Add-CountToMap -Map $statusCounts -Key $profile.ConnectionStatus
                    if ($profile.PSObject.Properties.Name -contains 'SplitTunneling' -and [bool]$profile.SplitTunneling) { $splitTunnelingEnabledCount++ }
                }

                $evidence = [ordered]@{ collection_completed = $true; profile_count = $profiles.Count; status_counts = $statusCounts; split_tunneling_enabled_count = $splitTunnelingEnabledCount; raw_profile_names_recorded = $false; all_user_profiles_queried = $false }
                $message = 'VPN profile presence summary collected without profile names.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result 'PASS' -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-wifi-profile-count-summary' {
                $netshAvailable = $null -ne (Get-Command -Name netsh.exe -ErrorAction SilentlyContinue)
                $profileCount = 0
                $netshSucceeded = $false

                if ($netshAvailable) {
                    $rawOutput = @(netsh.exe wlan show profiles 2>$null)
                    $netshSucceeded = ($LASTEXITCODE -eq 0)
                    foreach ($line in $rawOutput) {
                        if ([string]$line -match '^\s*(All User Profile|Current User Profile)\s*:') { $profileCount++ }
                    }
                }

                $wifiAdapterCount = 0
                if (Get-Command -Name Get-NetAdapter -ErrorAction SilentlyContinue) {
                    $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue)
                    foreach ($adapter in $adapters) {
                        $medium = if ($adapter.PSObject.Properties.Name -contains 'NdisPhysicalMedium') { [string]$adapter.NdisPhysicalMedium } else { '' }
                        $description = if ($adapter.PSObject.Properties.Name -contains 'InterfaceDescription') { [string]$adapter.InterfaceDescription } else { '' }
                        if ($medium -match '802\.11|Wireless' -or $description -match 'Wi-Fi|Wireless|802\.11') { $wifiAdapterCount++ }
                    }
                }

                $evidence = [ordered]@{ collection_completed = $true; netsh_available = $netshAvailable; netsh_wlan_query_succeeded = $netshSucceeded; wifi_profile_count = $profileCount; wifi_adapter_presence_count = $wifiAdapterCount; raw_profile_names_recorded = $false; raw_ssids_recorded = $false }
                $resultValue = if ($netshAvailable) { 'PASS' } else { 'WARN' }
                $message = 'Wi-Fi profile count summary collected without SSIDs or profile names.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-dhcp-client-service-status-summary' {
                $summary = Get-ServiceStateSummary -ServiceName 'Dhcp'
                $resultValue = if ($summary['service_present'] -and [string]$summary['status'] -eq 'Running') { 'PASS' } else { 'WARN' }
                $evidence = [ordered]@{ collection_completed = $true; service_summary = $summary; remediation_performed = $false; mutation_performed = $false }
                $message = 'DHCP Client service status summary collected without modifying the service.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-dns-client-service-status-summary' {
                $summary = Get-ServiceStateSummary -ServiceName 'Dnscache'
                $resultValue = if ($summary['service_present'] -and [string]$summary['status'] -eq 'Running') { 'PASS' } else { 'WARN' }
                $evidence = [ordered]@{ collection_completed = $true; service_summary = $summary; remediation_performed = $false; mutation_performed = $false }
                $message = 'DNS Client service status summary collected without modifying the service.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-nla-service-status-summary' {
                $summary = Get-ServiceStateSummary -ServiceName 'NlaSvc'
                $resultValue = if ($summary['service_present'] -and [string]$summary['status'] -eq 'Running') { 'PASS' } else { 'WARN' }
                $evidence = [ordered]@{ collection_completed = $true; service_summary = $summary; remediation_performed = $false; mutation_performed = $false }
                $message = 'Network Location Awareness service status summary collected without modifying the service.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-firewall-profile-summary' {
                if (-not (Get-Command -Name Get-NetFirewallProfile -ErrorAction SilentlyContinue)) {
                    $evidence = [ordered]@{ collection_completed = $false; command_available = $false }
                    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'WARN' -Message 'Firewall profile command is unavailable on this system.' -Evidence $evidence -EvidenceText 'Firewall profile command is unavailable on this system.'
                    return
                }

                $profiles = @(Get-NetFirewallProfile -ErrorAction Stop)
                $enabledCount = 0
                $disabledCount = 0
                $inboundActionCounts = New-EmptyCountMap
                $outboundActionCounts = New-EmptyCountMap

                foreach ($profile in $profiles) {
                    if ($profile.Enabled) { $enabledCount++ } else { $disabledCount++ }
                    Add-CountToMap -Map $inboundActionCounts -Key $profile.DefaultInboundAction
                    Add-CountToMap -Map $outboundActionCounts -Key $profile.DefaultOutboundAction
                }

                $evidence = [ordered]@{ collection_completed = $true; profile_count = $profiles.Count; enabled_profile_count = $enabledCount; disabled_profile_count = $disabledCount; default_inbound_action_counts = $inboundActionCounts; default_outbound_action_counts = $outboundActionCounts; firewall_settings_modified = $false }
                $resultValue = if ($profiles.Count -gt 0 -and $enabledCount -gt 0) { 'PASS' } else { 'WARN' }
                $message = 'Firewall profile summary collected without changing firewall settings.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-recent-dhcp-event-count-summary' {
                $summary = Get-EventCountSummary -LogName 'Microsoft-Windows-Dhcp-Client/Operational' -HoursBack 24
                $resultValue = if ($summary['log_available']) { 'PASS' } else { 'WARN' }
                $evidence = [ordered]@{ collection_completed = $true; event_summary = $summary; event_messages_recorded = $false; target_values_recorded = $false }
                $message = 'Recent DHCP event count summary collected without event messages or targets.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-recent-dns-client-event-count-summary' {
                $summary = Get-EventCountSummary -LogName 'Microsoft-Windows-DNS-Client/Operational' -HoursBack 24
                $resultValue = if ($summary['log_available']) { 'PASS' } else { 'WARN' }
                $evidence = [ordered]@{ collection_completed = $true; event_summary = $summary; event_messages_recorded = $false; target_values_recorded = $false }
                $message = 'Recent DNS client event count summary collected without event messages or target names.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'network-connectivity-guidance-plan' {
                $guidance = @(
                    'Classify whether the symptom affects one app, several apps, or all network activity.',
                    'Record whether the user is on wired, Wi-Fi, VPN, or a changing connection type.',
                    'Record when the symptom started and whether it is intermittent or constant.',
                    'Attach the sanitized network-evidence-v1 result files instead of raw identifiers.',
                    'Escalate with counts, categories, and observed warning states only.',
                    'Do not flush, release, renew, restart, disable, enable, or reconfigure anything from this layer.'
                )
                $evidence = [ordered]@{ collection_completed = $true; plan_type = 'read_only_connectivity_guidance'; step_count = $guidance.Count; guidance_steps = $guidance; remediation_performed = $false; mutation_performed = $false; target_values_requested = $false }
                $message = 'Read-only connectivity guidance plan generated.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result 'PASS' -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            'ticket-ready-network-question-plan' {
                $questions = @(
                    'What symptom category best describes the issue: no connection, slow connection, intermittent connection, app-specific issue, sign-in issue, or VPN-related issue?',
                    'Which connection type was in use when the issue occurred: wired, Wi-Fi, VPN, or unknown?',
                    'When did the issue start, and is it constant or intermittent?',
                    'Does the issue affect only one device, several devices, or the user cannot tell?',
                    'Does the issue affect one app, several apps, or all network activity?',
                    'Were there recent changes the user is allowed to describe generically, such as location change, new device, or new connection type?',
                    'Can the user attach the sanitized result files generated by this layer?',
                    'Do not request or paste raw addresses, device names, account names, server names, share names, printer names, SSIDs, or VPN profile names.'
                )
                $evidence = [ordered]@{ collection_completed = $true; plan_type = 'ticket_ready_network_questions'; question_count = $questions.Count; questions = $questions; raw_identifier_collection_requested = $false; remediation_performed = $false; mutation_performed = $false }
                $message = 'Ticket-ready network question plan generated.'
                Write-NetworkEvidenceResult -ActionId $ActionId -Result 'PASS' -Message $message -Evidence $evidence -EvidenceText $message
                return
            }

            default {
                $evidence = [ordered]@{ collection_completed = $false; unsupported_slug = $true }
                Write-NetworkEvidenceResult -ActionId $ActionId -Result 'FAIL' -Message 'Unsupported network evidence action slug.' -Evidence $evidence -EvidenceText 'Unsupported network evidence action slug.'
                exit 1
            }
        }
    }
    catch {
        $safeError = $_.Exception.GetType().Name
        $evidence = [ordered]@{ collection_completed = $false; error_category = $safeError }
        Write-NetworkEvidenceResult -ActionId $ActionId -Result 'FAIL' -Message 'Collection failed before a sanitized result could be completed.' -Evidence $evidence -EvidenceText 'Collection failed before a sanitized result could be completed.'
        exit 1
    }
}