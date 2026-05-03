# Support Scenario Network V1 Plan

## Purpose

network-evidence-v1 gives help desk and local IT a safe, no-admin way to collect Windows network troubleshooting context without changing the machine or exposing workplace identifiers.

## Scenario fit

Use this layer when a user reports no connection, slow connection, intermittent connection, app-specific connectivity symptoms, VPN-related symptoms, Wi-Fi profile uncertainty, or DHCP/DNS suspicion that needs sanitized evidence before escalation.

## Safety model

This layer is read-only. It does not flush DNS, release or renew DHCP, restart services, change adapters, change routes, change firewall settings, change proxy settings, change DNS settings, change VPN settings, scan networks, or test target systems.

## Evidence model

The layer collects command readiness, adapter counts, IP configuration presence, DNS client setting presence, gateway presence, route counts, metric categories, profile categories, proxy setting presence, VPN profile counts, Wi-Fi profile counts, service state summaries, firewall profile categories, recent DHCP/DNS event counts, and ticket-ready guidance.

## Escalation use

A ticket can include the sanitized result files and the generated question plan. The ticket should avoid raw addresses, names, suffixes, profile names, and internal targets unless a separate approved support workflow explicitly requests them.