# Set certificate for Windows Admin Center

param($result)

$SME_PORT=$(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManagementGateway -Name "SmePort").SmePort
$SME_THUMBPRINT=$($result.ManagedItem.CertificateThumbprintHash)
$APP_GUID=$(New-Guid).Guid

# Stop Service
Stop-Service ServerManagementGateway

# Fix SSL
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManagementGateway -Name "UseHttps" -Value 1

# Apply certificate
"http delete sslcert ipport=0.0.0.0:$SME_PORT" | netsh
"http delete urlacl url=https://+:$SME_PORT/" | netsh
"http add sslcert ipport=0.0.0.0:$SME_PORT certhash=$SME_THUMBPRINT appid={$APP_GUID}" | netsh
"http add urlacl url=https://+:$SME_PORT/ user=""NT Authority\Network Service""" | netsh

#Start Service
Start-Service ServerManagementGateway
