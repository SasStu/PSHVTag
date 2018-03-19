function Get-EdgeHashtableFromVMNote
{
    <#
    .SYNOPSIS
    Creates a hashtable with KeyProperty as Key and Value property as (an array of) Value(s)
    
    .DESCRIPTION
    Creates a hashtable with KeyProperty as Key and Value property as (an array of) Value(s)
    
    .PARAMETER VM
    A VMwithTag object
    
    .PARAMETER KeyProperty
    The property of the VM object which should be used as Key in the hashtable to create
    
    .PARAMETER ValueProperty
    The property of the VM object to use as value of the hashtable to create
    
    .EXAMPLE
    Get-EdgeHashtableFromVMNote -VM $VM -KeyProperty Service -ValueProperty DependsOn
        
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(

        # Vm object with tags
        [Parameter(Mandatory = $true)]
        [VMwithTag[]]
        $VM,
        #Property to use as Key
        [Parameter(Mandatory = $true)]
        [string]
        $KeyProperty,
        #Property to use as Value
        [Parameter(Mandatory = $true)]
        [string]
        $ValueProperty
    )

    $EdgeList = @{}
    foreach ($Node in $VM)
    {
        Write-Verbose -Message ('Processing VM ' + $Node.Name + ' Key Property: ' + $KeyProperty)
        Foreach ($Key in $Node.$KeyProperty)
        {
            Write-Verbose -Message ('Processing VM ' + $Node.Name + ' Key Property: ' + $KeyProperty + ' Key value: ' + $Key)
            If (!($EdgeList.ContainsKey($Key)))
            {
                Write-Verbose -Message ('Creating new Key for ' + $Key)
                $EdgeList.Add($Key, $null)                
            }
            Foreach ($Value in $Node.$ValueProperty)
            {
                Write-Verbose -Message ('Processing VM ' + $Node.Name + ' Key Property: ' + $Key + ' Value Property: ' + $Value)
                If ($EdgeList.Item($Key) -notcontains $Value)
                {
                    Write-Verbose -Message ('Adding ' + $Value + ' to Key Property ' + $Key + ' values')
                    [array]$EdgeList.Item($Key) += [string]$Value
                }
            }
        }
    }
    $EdgeList #.GetEnumerator() | Sort-Object -Property Name
}