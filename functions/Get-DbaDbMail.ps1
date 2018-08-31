﻿function Get-DbaDbMail {
    <#
    .SYNOPSIS
        Gets the databaes mail from a SQL instance

    .DESCRIPTION
        Gets the databaes mail from a SQL instance

    .PARAMETER SqlInstance
        The SQL Server instance, or instances.

    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
        Tags: databasemail
        Website: https://dbatools.io
        Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://dbatools.io/Get-DbaDbMail

    .EXAMPLE
        Get-DbaDbMail -SqlInstance sql01\sharepoint

        Returns the db mail server object on sql01\sharepoint

    .EXAMPLE
        Get-DbaDbMail -SqlInstance sql01\sharepoint | Select *

        Returns the db mail server object on sql01\sharepoint then return a bunch more columns

    .EXAMPLE
        $servers = "sql2014","sql2016", "sqlcluster\sharepoint"
        $servers | Get-DbaDbMail

       Returns the db mail server object for "sql2014","sql2016" and "sqlcluster\sharepoint"

#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [Alias("Credential")]
        [PSCredential]$SqlCredential,
        [switch]$EnableException
    )
    process {
        foreach ($instance in $SqlInstance) {
            Write-Message -Level Verbose -Message "Connecting to $instance"
            
            try {
                $server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $SqlCredential
            }
            catch {
                Stop-Function -Message "Failure" -Category Connectiondbmail -dbmailRecord $_ -Target $instance -Continue
            }
            
            try {
                $mailserver = $server.Mail
                Add-Member -Force -InputObject $mailserver -MemberType NoteProperty -Name ComputerName -value $server.ComputerName
                Add-Member -Force -InputObject $mailserver -MemberType NoteProperty -Name InstanceName -value $server.ServiceName
                Add-Member -Force -InputObject $mailserver -MemberType NoteProperty -Name SqlInstance -value $server.DomainInstanceName
                $mailserver | Select-DefaultView -Property ComputerName, InstanceName, SqlInstance, Profiles, Accounts, ConfigurationValues, Properties
            }
            catch {
                Stop-Function -Message "Query failure" -ErrorRecord $_ -Continue
            }
        }
    }
}