#This script will enable non-owner mailbox access auditing on every mailbox in your tenancy
#First, let's get us a cred!
$userCredential = Get-Credential


#Open PSSession
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -Name Get-Mailbox, Set-Mailbox

#User input desired log age limit
$AuditLogAge = Read-Host -Prompt 'Input the desired log age in days'

#Enable global audit logging - by default all mailbox types are choosen (User,Shared,Room and Discovery)
foreach ($mailbox in Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox" -or RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "DiscoveryMailbox"})
{
    try
    {
        Set-Mailbox -Identity $mailbox.DistinguishedName -AuditEnabled $true -AuditLogAgeLimit $AuditLogAge -AuditAdmin UpdateFolderPermissions, MoveToDeletedItems, HardDelete, UpdateInboxRules -AuditDelegate UpdateFolderPermissions, MoveToDeletedItems, HardDelete, UpdateInboxRules -AuditOwner $false
    }
    catch
    {
        Write-Warning $_.Exception.Message
    }
}

#Double-Check It!
Get-Mailbox -ResultSize Unlimited | Select Name, AuditEnabled, AuditLogAgeLimit