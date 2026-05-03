$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0
. (Join-Path $PSScriptRoot "..\lib\Common-FileAccessEvidenceV1.ps1")
$ActionId = "ENDUSER_FILE_ACCESS_OFFICE_FILE_ASSOCIATION_DOCX_SUMMARY_V1"
$Kind = "assoc_docx"
try {
    $Evidence = [ordered]@{}
    switch ($Kind) {
        "package_readiness" { $Evidence["package_mode"]="local_ticket_ready_file_access_evidence"; $Evidence["mutation_allowed"]=$false; $Evidence["admin_required"]=$false; $Evidence["raw_file_content_collection"]=$false; $Evidence["raw_path_collection_in_git"]=$false }
        "known_folder_presence" { $Evidence["desktop"]=Get-KnownFolderPresenceSafe -FolderName "Desktop"; $Evidence["documents"]=Get-KnownFolderPresenceSafe -FolderName "MyDocuments"; $Evidence["raw_paths_collected"]=$false }
        "known_folder_item_counts" { $Ext=@(".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".pdf", ".txt"); $Evidence["desktop"]=Get-TopLevelFileCountSafe -FolderName "Desktop" -Extensions $Ext; $Evidence["documents"]=Get-TopLevelFileCountSafe -FolderName "MyDocuments" -Extensions $Ext; $Evidence["file_names_collected"]=$false; $Evidence["paths_collected"]=$false }
        "onedrive_env_presence" { $Evidence["onedrive_env_present"]=[bool]($env:OneDrive); $Evidence["onedrive_commercial_env_present"]=[bool]($env:OneDriveCommercial); $Evidence["onedrive_consumer_env_present"]=[bool]($env:OneDriveConsumer); $Evidence["env_values_collected"]=$false }
        "onedrive_process" { $Evidence["onedrive_process_count"]=@(Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue).Count; $Evidence["process_paths_collected"]=$false }
        "onedrive_sync_root_count" { $Roots=@(); if($env:OneDrive){$Roots+=$env:OneDrive}; if($env:OneDriveCommercial){$Roots+=$env:OneDriveCommercial}; if($env:OneDriveConsumer){$Roots+=$env:OneDriveConsumer}; $Existing=@($Roots | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path $_) }); $Evidence["sync_root_env_count"]=$Roots.Count; $Evidence["sync_root_existing_count"]=$Existing.Count; $Evidence["sync_root_values_collected"]=$false }
        "sharepoint_shortcut_presence" { $Count=0; if($env:OneDriveCommercial -and (Test-Path $env:OneDriveCommercial)){ $Count=@(Get-ChildItem -Path $env:OneDriveCommercial -Directory -ErrorAction SilentlyContinue).Count }; $Evidence["sharepoint_shortcut_indicator_count"]=$Count; $Evidence["shortcut_names_collected"]=$false; $Evidence["shortcut_paths_collected"]=$false }
        "assoc_docx" { $Evidence["association"] = Get-AssociationPresenceSafe -Extension ".docx" }
        "assoc_xlsx" { $Evidence["association"] = Get-AssociationPresenceSafe -Extension ".xlsx" }
        "assoc_pptx" { $Evidence["association"] = Get-AssociationPresenceSafe -Extension ".pptx" }
        "recent_office_extension_counts" { $Ext=@(".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx"); $Evidence["desktop"]=Get-TopLevelFileCountSafe -FolderName "Desktop" -Extensions $Ext; $Evidence["documents"]=Get-TopLevelFileCountSafe -FolderName "MyDocuments" -Extensions $Ext; $Evidence["file_names_collected"]=$false; $Evidence["paths_collected"]=$false }
        "recent_file_error_events" { $Evidence["application_error_count_24h"] = Get-EventCountSafe -LogName "Application" -Hours 24 -Level 2; $Evidence["system_error_count_24h"] = Get-EventCountSafe -LogName "System" -Hours 24 -Level 2; $Evidence["raw_event_text_collected"]=$false }
        "explorer_recent_items_count" { $Evidence["recent_items"] = Get-RecentShortcutCountSafe }
        "offline_files_service" { $Evidence["cscservice"] = Get-ServiceStateSafe -Name "CscService"; $Evidence["mutation_performed"]=$false }
        "work_folders_service" { $Evidence["workfolderssvc"] = Get-ServiceStateSafe -Name "workfolderssvc"; $Evidence["mutation_performed"]=$false }
        "mapped_drive_count" { $Mapped=@(Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue | Where-Object { $_.DisplayRoot }); $Evidence["mapped_drive_count"]=$Mapped.Count; $Evidence["drive_letters_collected"]=$false; $Evidence["unc_paths_collected"]=$false }
        "network_profile_count" { $Profiles=@(Get-NetConnectionProfile -ErrorAction SilentlyContinue); $Evidence["profile_count"]=$Profiles.Count; $Evidence["public_count"]=@($Profiles | Where-Object { $_.NetworkCategory -eq "Public" }).Count; $Evidence["private_count"]=@($Profiles | Where-Object { $_.NetworkCategory -eq "Private" }).Count; $Evidence["domain_authenticated_count"]=@($Profiles | Where-Object { $_.NetworkCategory -eq "DomainAuthenticated" }).Count; $Evidence["network_names_collected"]=$false }
        "indexing_service" { $Evidence["wsearch"] = Get-ServiceStateSafe -Name "WSearch"; $Evidence["mutation_performed"]=$false }
        "default_save_location_plan" { $Evidence["plan_only"]=$true; $Evidence["check_known_folders"]=$true; $Evidence["check_onedrive_status"]=$true; $Evidence["check_office_default_save_behavior"]=$true; $Evidence["mutation_allowed"]=$false }
        "ticket_ready_question_plan" { $Evidence["plan_only"]=$true; $Evidence["question_set_included"]=$true; $Evidence["private_answers_collected"]=$false; $Evidence["mutation_allowed"]=$false }
        default { $Evidence["unknown_kind"]=$Kind }
    }
    Write-FileAccessEvidenceResult -ActionId $ActionId -Result "PASS" -Message "Collected sanitized file-access evidence summary without changing the system." -Evidence $Evidence
} catch {
    $Evidence = [ordered]@{ error_type=$_.Exception.GetType().FullName; sanitized=$true }
    Write-FileAccessEvidenceResult -ActionId $ActionId -Result "FAIL" -Message "File access evidence action failed before completion; error detail was sanitized." -Evidence $Evidence
    exit 1
}
