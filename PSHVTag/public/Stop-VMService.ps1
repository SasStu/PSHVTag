function Stop-VMService
{
    <#
    .SYNOPSIS
    Stopps all VMs of a VM Service in a VM Topology
    
    .DESCRIPTION
    Stopps all VMs of a VM Service in a VM Topology and all VMs of required Vm Services
    
    .PARAMETER ServiceName
    The name of the VM Service to start
    
    .PARAMETER EnvironmentName
    The name of the VM Environment the VM Service is in
    
    .PARAMETER Service
    VMService object of the VM Service to stop
    
    .PARAMETER Environment
    VMEnvironment object of the VM Service to stop
    
    .PARAMETER VMTopology
    The VMTopology containing all VM Services and Environments
    
    .PARAMETER Recurse
    Stop all required VM Services after stopping the current VM Service 
    
    .PARAMETER Force
    Force shutdown of VMs
    
    .EXAMPLE
    Stop-VMService -ServiceName Domain -EnvironmentName Lab -VMTopology (Get-VMTopology) -Recurse
    
    #>
    [CmdletBinding(DefaultParameterSetName = 'String', SupportsShouldProcess = $true)]
    [OutputType([Bool])]
    param(
        # Name of the VM Service to stop
        [Parameter(ParameterSetName = 'String', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Object-String', Mandatory = $true)]     
        [string]
        $ServiceName,
        # Name of the Environment of the service to stop
        [Parameter(ParameterSetName = 'String', Mandatory = $true)]
        [Parameter(ParameterSetName = 'String-Object', Mandatory = $true)]
        [string]
        $EnvironmentName,
        # Name of the VM Service to stop
        [Parameter(ParameterSetName = 'Object', Mandatory = $true)]
        [Parameter(ParameterSetName = 'String-Object', Mandatory = $true)]     
        [VMService]
        $Service,
        # Name of the Environment of the service to stop
        [Parameter(ParameterSetName = 'Object', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Object-String', Mandatory = $true)]     
        [VMEnvironment]
        $Environment,
        # VMTopology
        [Parameter(Mandatory = $true)]
        [VMTopology]
        $VMTopology,
        # Stop VM Services recursively
        [Parameter()]
        [switch]
        $Recurse,
        # Force stopping of VM
        [Parameter()]
        [switch]
        $Force
    )
    Begin
    {
        switch ($PsCmdlet.ParameterSetName)
        {
            'Object'
            { 
                $ServiceName = $Service.Name
                $EnvironmentName = $Environment.Name
            }
            'Object-String'
            {
                $EnvironmentName = $Environment.Name
            }
            'String-Object'
            {
                $ServiceName = $Service.Name
            }
        }
        $Service = ($VMTopology.Environment | where-object -property name -eq $EnvironmentName).Service | Where-Object Name -eq $ServiceName
        If (!($Service))
        {
            Throw ('Could not find the service ' + $ServiceName + ' in the environment ' + $EnvironmentName)
        }
    }
    Process
    {
        foreach ($Node in $Service.VM)
        {
            If ($Node.VM.State -ne 'Off')
            {
                if ($PSCmdlet.ShouldProcess(('Stopping VM: ' + $Node.Name)))
                {
                    If ($Force)
                    {
                        $State = Stop-VM -VM $Node.Vm -Passthru -Force
                    }
                    else
                    {
                        $State = Stop-VM -VM $Node.Vm -Passthru
                    }
                    If (!($State.State -eq 'Off'))
                    {
                        Throw ('Could not stop VM: ' + $Node.Name)
                    }
                }
            }            
        }
        if ($Recurse)
        {
            foreach ($Dependency in $Service.DependsOn )
            {
                Write-Verbose ('Stopping required service: ' + $Dependency)
                If ($Force)
                {
                    Stop-VMService -ServiceName $Dependency -EnvironmentName $EnvironmentName -VMTopology $VMTopology -Recurse -Force | Out-Null
                }
                else
                {
                    Stop-VMService -ServiceName $Dependency -EnvironmentName $EnvironmentName -VMTopology $VMTopology -Recurse | Out-Null
                }
            }
        }
    }
    End
    {
        Write-Verbose ('Successfully stopped VM Service: ' + $ServiceName)
        $true
    }
}