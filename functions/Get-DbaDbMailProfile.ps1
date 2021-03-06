﻿function Get-DbaDbMailProfile {
    <#
    .SYNOPSIS
        Gets database mail profiles from SQL Server

    .DESCRIPTION
        Gets database mail profiles from SQL Server

    .PARAMETER SqlInstance
        The SQL Server instance, or instances.

    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)

    .PARAMETER Profile
        Specifies one or more profile(s) to get. If unspecified, all profiles will be returned.

    .PARAMETER ExcludeProfile
        Specifies one or more profile(s) to exclude.

    .PARAMETER InputObject
        Accepts pipeline input from Get-DbaDbMail
    
    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
        Tags: databasemail, dbmail, mail
        Author: Chrissy LeMaire (@cl), netnerds.net
        Website: https://dbatools.io
        Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://dbatools.io/Get-DbaDbMailProfile

    .EXAMPLE
        Get-DbaDbMailProfile -SqlInstance sql01\sharepoint

        Returns dbmail profiles on sql01\sharepoint

    .EXAMPLE
        Get-DbaDbMailProfile -SqlInstance sql01\sharepoint -Profile 'The DBA Team'

        Returns The DBA Team dbmail profile from sql01\sharepoint
    
    .EXAMPLE
        Get-DbaDbMailProfile -SqlInstance sql01\sharepoint | Select *

        Returns the dbmail profiles on sql01\sharepoint then return a bunch more columns

    .EXAMPLE
        $servers = "sql2014","sql2016", "sqlcluster\sharepoint"
        $servers | Get-DbaDbMail | Get-DbaDbMailProfile

       Returns the db dbmail profiles for "sql2014","sql2016" and "sqlcluster\sharepoint"

#>
    [CmdletBinding()]
    param (
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [Alias("Credential")]
        [PSCredential]$SqlCredential,
        [string[]]$Profile,
        [string[]]$ExcludeProfile,
        [Parameter(ValueFromPipeline)]
        [Microsoft.SqlServer.Management.Smo.Mail.SqlMail[]]$InputObject,
        [switch]$EnableException
    )
    process {
        foreach ($instance in $SqlInstance) {
            Write-Message -Level Verbose -Message "Connecting to $instance"
            $InputObject += Get-DbaDbMail -SqlInstance $SqlInstance -SqlCredential $SqlCredential
        }
        
        if (-not $InputObject) {
            Stop-Function -Message "No servers to process"
            return
        }
        
        foreach ($mailserver in $InputObject) {
            try {
                $profiles = $mailserver.Profiles
                
                if ($Profile) {
                    $profiles = $profiles | Where-Object Name -in $Profile
                }
                
                If ($ExcludeProfile) {
                    $profiles = $profiles | Where-Object Name -notin $ExcludeProfile
                    
                }
                
                $profiles | Add-Member -Force -MemberType NoteProperty -Name ComputerName -value $mailserver.ComputerName
                $profiles | Add-Member -Force -MemberType NoteProperty -Name InstanceName -value $mailserver.InstanceName
                $profiles | Add-Member -Force -MemberType NoteProperty -Name SqlInstance -value $mailserver.SqlInstance
                
                $profiles | Select-DefaultView -Property ComputerName, InstanceName, SqlInstance, ID, Name, Description, ForceDeleteForActiveProfiles, IsBusyProfile
            }
            catch {
                Stop-Function -Message "Failure" -ErrorRecord $_ -Continue
            }
        }
    }
}