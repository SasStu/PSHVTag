function Set-VMTag
{
    <#
    .SYNOPSIS
    Tag a VM
    
    .DESCRIPTION
    This function tags one or more VMs with the Environment, Service and DependsOn Tag
    
    .PARAMETER Environment
    The environment the VM belongs to
    
    .PARAMETER Service
    The service the VM provides
    
    .PARAMETER DependsOn
    The Services the VM depends on
    
    .PARAMETER VMName
    The name of the VM
    
    .PARAMETER VM
    The VM object
    
    .PARAMETER Computername
    The VM host
    
    .PARAMETER Force
    Overwrite existing values
    
    .EXAMPLE
    Set-VMTag -Environment 'LAB01' -Service 'Domain' -DependsOn @('Gateway','DHCP') -VMName 'DomainController01' -Force
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    
    param(
        # Name of the VMEnvironment the VM belongs to
        [Parameter(Mandatory = $false)]
        [string[]]
        $Environment,
        # Name of the VMService the VM provides
        [Parameter(Mandatory = $false)]
        [string[]]
        $Service,
        # Name of the VMServices the VM depends on
        [Parameter(Mandatory = $false)]
        [string[]]
        $DependsOn,
        # The name of the VM
        [Parameter(ParameterSetName = 'Name', Mandatory = $true)]
        [string[]]
        $VMName,
        # The VM object
        [Parameter(ParameterSetName = 'VMObject', Mandatory = $true)]
        $VM,
        # Specifies the VM Host.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Computername = 'localhost',
        # Force overwrite of existing Tag
        [Parameter()]
        [switch]
        $Force
    )
    Begin
    {
        $TagPattern = '\<Env\>.*\<\/Env\>\<Service\>.*\<\/Service\>\<DependsOn\>.*\<\/DependsOn\>'
        $returnObject = [pscustomobject]@{ Success = @(); Error = @()} 
        If ($PSCmdlet.ParameterSetName -eq 'Name')
        {
            $VM = @()
            foreach ($Name in $VMName)
            {
                try
                {
                    $VM += Get-VM -ComputerName $Computername | Where-Object -Property Name -EQ $Name
                }
                catch
                {
                    Write-Verbose "Can not find a VM with the name $Name at the host $Computername"
                    $returnObject.Error += $Name    
                }
            }
        }
        If (!($Vm))
        {
            Throw 'Can not find any VM for these parameters'
        }
    }
    Process
    {
        foreach ($Node in $VM)
        {
            If ($Node.Notes -Match $TagPattern -and (-not $Force))
            {
                Write-Verbose -Message "VM: $($VM.Name) already has a Tag and the paramater -force is not used"
                $returnObject.Error += $Node.Name  
            }
            elseif (($Node.Notes -Match $TagPattern -and $Force) -or ($Node.Notes -notMatch $TagPattern))
            {
                $Tag = '<Env>' + ($Environment -join ',') + '</Env><Service>' + ($Service -join ',') + '</Service><DependsOn>' + ($DependsOn -join ',') + '</DependsOn>'
                if ($Node.Notes -Match $TagPattern)
                {
                    $NewNotes = $Node.Notes -replace $TagPattern, $Tag
                }
                Elseif ($null -ne $Node.Notes -and $Node.Notes -ne '')
                {
                    $NewNotes = $Node.Notes + "`r`n" + $Tag + "`r`n"
                }
                Else
                {
                    $NewNotes = $Tag + "`r`n"
                }
                Write-Verbose -Message "Setting Tag on VM $($VM.Name) to $NewNotes"
                if ($PSCmdlet.ShouldProcess(('Setting VM Notes of: ' + $Node.Name + ' to ' + $NewNotes)))
                {
                    Try
                    {
                        Set-Vm -VM $Node -Notes $NewNotes
                        $returnObject.Success += $Node.Name 
                    }
                    catch
                    {
                        Write-Verbose -Message "Could not set Tag on VM $($VM.Name) to $NewNotes"
                        $returnObject.Error += $Node.Name 
                    }
                }
            }
        }
    }
    End
    {
        $returnObject
    }
}