function Get-VMService
{
    <#
    .SYNOPSIS
    Creates a (array of) VMService object(s)
    
    .DESCRIPTION
    Creates a (array of) VMService object(s) based on the list of tagged VMs defined by the parameter VM.
    
    .PARAMETER VM
    A (list of) VM object(s) with Tags from which to build the VMEnvironment object
    
    .EXAMPLE
    Get-VMService -VM (Get-VMWithTag | Convert-VMNoteTagsToObject)
    
    #>
    [CmdletBinding()]
    [OutputType([array])]
    param(
        # VM with Tag object gathered by Convert-VMNoteTagsToObject
        [Parameter(Mandatory = $true)]
        [VMWithTag[]] 
        $VM
    )
    $EdgeList = Get-EdgeHashtableFromVMNote -VM $VM -KeyProperty 'Service' -ValueProperty 'DependsOn'
    [array]$VMService = @()
    foreach ($Service in $EdgeList.Keys)
    {
        [array]$VmService += [VMService]::new($Service, ($VM | Where-Object -Property Service -eq $Service), $EdgeList.Item($Service))
    }
    $VMService
}