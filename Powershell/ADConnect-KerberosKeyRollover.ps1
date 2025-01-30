# Automated Kerberos Rollover Script by @aftereffexts
# Place this Script on ADCONNECT Server and Schedule it for 30 days (or howlong u wanna enroll a new key)
# Change every Variables also the "@urmom.com" ones


$CloudUser = 'changeme@urmom.onmicrosoft.com'
$CloudEncrypted = Get-Content "C:\path\to\creds\Azure_Encrypted.txt" | ConvertTo-SecureString
$CloudCred = New-Object System.Management.Automation.PsCredential($CloudUser,$CloudEncrypted)

$OnpremUser = 'domain\urmom'
$OnpremEncrypted = Get-Content "C:\path\to\creds\Onprem_Encrypted.txt" | ConvertTo-SecureString
$OnpremCred = New-Object System.Management.Automation.PsCredential($OnpremUser,$OnpremEncrypted)

#This Path is always the same on AD Connect Server
Import-Module 'C:\Program Files\Microsoft Azure Active Directory Connect\AzureADSSO.psd1'
New-AzureADSSOAuthenticationContext -CloudCredentials $CloudCred

# Run the command and log it so the logs can be send via email
$loglocation = "C:\path\to\creds\Rollover_Kerberos.log"
Start-Transcript -Path $loglocation

Update-AzureADSSOForest -OnPremCredentials $OnpremCred

Stop-Transcript

#Stops logging

$output = (Get-Content $loglocation -raw) -replace '(.+\n)+(.+)?(?=output file is)'
$output | Out-File $loglocation

#Email Body Text
$emailbody = "The Kerberos decryption key rollover command ran on $env:COMPUTERNAME via scheduled task. See output of the command below to confirm it was successful.`n`n"
$emailbody = $emailbody + $(Get-Content $loglocation -raw)

############
#SEND EMAIL#
############
$EmailUser = "no-reply@urmom.com"
$EmailEncrypted = Get-Content "C:\path\to\creds\Email_Encrypted.txt" | ConvertTo-SecureString
$EmailCred = New-Object System.Management.Automation.PsCredential($EmailUser, $EmailEncrypted)

###########Define Variables Below######## 
$fromaddress = "no-reply@urmom.com"
$toaddresses = @("FIRSTMAIL@urmom.com", "SECONDMAIL@urmom.com")
$Subject = "$env:COMPUTERNAME - Kerberos Key Rollover - $(get-date -Format dd-MM-yyyy)" 
$body = $emailbody
$smtpserver = "SMTP.urmom.com" 
$smtpport = 587 # Change according to your mail server
#################################### 
#######FUNCTION FOR MAIL SENDING####
$message = New-Object System.Net.Mail.MailMessage 
$message.From = $fromaddress 

# Loop through and add multiple recipients in the $toaddresses array above.
foreach ($toaddress in $toaddresses)
{
    $message.To.Add($toaddress) 
}

$message.IsBodyHtml = $False 
$message.Subject = $Subject 
$message.body = $body

$smtp = New-Object Net.Mail.SmtpClient($smtpserver, $smtpport) 
$smtp.Credentials = $EmailCred
$smtp.EnableSsl = $True # Ensure SSL is enabled if required by the mail server
$smtp.Send($message)
