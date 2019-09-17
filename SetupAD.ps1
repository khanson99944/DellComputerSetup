﻿#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [string]
    $ComputerName,
    [string] #All ready coming is as secure string that is in string form
    $SecuredPass,
    [string] 
    $UserName,
    [string]
    $Path
)


#import shared functions
Import-Module $Path\Functions.psm1
$Config = select-xml -Path "$PSScriptRoot\config.xml" -XPath "//config" | Select-Object -ExpandProperty "node"

#checks if task exists
$taskexist = Get-ScheduledTask -TaskName $Config.general.taskname -ErrorAction Ignore
#removes task if it exists
if($taskexist){
  Unregister-ScheduledTask -TaskName $Config.general.taskname -Confirm:$false
}

#creates the credentials for the script
if ($UserName -notlike $null -and $SecuredPass -notlike $null){
    $ConvertedPassword = ConvertTo-SecureString $SecuredPass
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName,$ConvertedPassword 
}else{
    $credential = Get-Credential
}


#trys to connect to AD. If it fails it repeats asking for credentiasl
$success = $false
do{
    try{
        $addCompItems = @{
            DomainName = $Config.general.domain
            Credential = $credential
            Restart = $true
            ErrorAction = "stop"  
            OUPath = $Config.general.ou
        }
        Add-Computer @addCompItems
        $success = $true
    }catch{
        write-error -Message $_
        Write-host "Please insert Credentials again or end the program"

        $credential = Get-Credential -UserName $UserName
    }
       
} until ($success)



Write-host "CONGRATULATIONS YOU HAVE COMPLETED THE SET UP!!!!!!!!" -ForegroundColor Green





 