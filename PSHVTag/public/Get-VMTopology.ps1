function Get-VMTopology
{
    <#
    .SYNOPSIS
    Gets a VM Topology object for tagged VMs
    
    .DESCRIPTION
    Gets a VM Topology object for tagged VMs on the Hyper-V-Host defined by the paramater Computername
    
    .PARAMETER Computername
    A Hyper-V-Host with tagged VMs
    
    .EXAMPLE
    Get-VMTopology -Computername hyper-v-host.contoso.com
    
    #>
    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string]
        $Computername = 'localhost'
    )
    $VM = Get-VMWithTag -Computername $Computername | ForEach-Object {Convert-VMNoteTagsToObject -VM $_}
    $Environment = Get-VMEnvironment -VM $VM
    $VMTopology = [VMTopology]::new($Computername, $VM, $Environment)
    $VMTopology
}