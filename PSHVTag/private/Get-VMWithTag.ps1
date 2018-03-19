function Get-VMWithTag
{
    <#
    .SYNOPSIS
    Gets all VMs containing Tags on a given host
    
    .DESCRIPTION
    Gets all VMs containing Tags on a Hyper-V-Host given by the parameter Computername
    
    .PARAMETER Computername
    The Hyper-V-Host getting the VMs conatining Tags from
    
    .EXAMPLE
    Get-VMWithTag -Computername localhost
    
    #>
    [CmdletBinding()]
    param(
        # Specifies the VM Host.
        [Parameter(Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Name of VM Host computer(s)")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Computername = 'localhost'
    )
    Get-VM -ComputerName $Computername | Where-Object {$_.Notes -match '\<.*\>'}
}
