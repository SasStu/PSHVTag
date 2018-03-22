function Convert-VMNoteTagsToObject
{
    <#
    .SYNOPSIS
    Converts a Vm object to Vm object including tags
    
    .DESCRIPTION
    Converts a Hyper-V VM object including State, Status and Notes to a VMWithTag Object including the custom Tag information
    
    .PARAMETER VM
    A Hyper-V VM object including, State, Status and Notes.
    
    .EXAMPLE
    Get-VM -Name 'Test1' | Convert-VMNoteTagsToObject
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        $VM
    )
    $VM.Notes -Match '(\<Env\>(?<Environment>.+)\<\/Env\>|\<Service\>(?<Service>.+)\<\/Service\>|\<DependsOn\>(?<DependsOn>.+)\<\/DependsOn\>)+' |Out-Null
    #[VMWithTag]::new('PI-LAB-GW03',(New-Guid),'PI-LAB','Network',@('HY','AZ'))
    #$VmWithTag = [VMWithTag]::new($VM.Name, $Vm, ($Matches.Environment -split ','), ($Matches.Service -split ','), ($Matches.DependsOn -split ','))
    $VmWithTag = [VMWithTag]::new($VM.Name, $Vm, ($Matches.Environment -split ',' | Where-Object {$_ -ne ''}), ($Matches.Service -split ','| Where-Object {$_ -ne ''}), ($Matches.DependsOn -split ','| Where-Object {$_ -ne ''}))
    $VmWithTag
}