function Get-VMEnvironment
{
    <#
    .SYNOPSIS
    Creates a (array of) VMEnvironment object(s)
    
    .DESCRIPTION
    Creates a (array of) VMEnvironment object(s) based on the list of tagged VMs defnied by the parameter VM.
    
    .PARAMETER VM
    A (list of) VM object(s) with Tags from which to build the VMEnvironment object
    
    .EXAMPLE
    Get-VMEnvironment -VM (Get-VMWithTag | Convert-VMNoteTagsToObject)
    
    #>
    [CmdletBinding()]
    param(
        # VM with Tag object gathered by Convert-VMNoteTagsToObject
        [Parameter(Mandatory = $true)]
        [VMWithTag[]] 
        $VM
    )
    $EdgeList = (Get-EdgeHashtableFromVMNote -VM $VM -KeyProperty 'Environment' -ValueProperty 'Service')
    [array]$VMEnvironment = @()
    foreach ($Environment in $EdgeList.Keys)
    {
        $EnvironmentVM = $VM | Where-Object -Property Environment -eq $Environment
        $Service = Get-VMService -VM $EnvironmentVM
        $EnvironmentServiceEdgeList = Get-EdgeHashtableFromVMNote -VM $EnvironmentVM -KeyProperty 'Service' -ValueProperty 'DependsOn'
        $EnvironmentOrder = Get-TopologicalSort -edgeList $EnvironmentServiceEdgeList
        If (Compare-Object -ReferenceObject ($Service | Select-Object -ExpandProperty Name) -DifferenceObject $EnvironmentOrder)
        {
            Throw 'One or more required services are not provided by a VM'
        }
        [array]$VMEnvironment += [VMEnvironment]::new($Environment, $Service, $EnvironmentVM, $EnvironmentServiceEdgeList, $EnvironmentOrder)
    }
    $VMEnvironment
}