function Start-VMService
{
    <#
    .SYNOPSIS
    Starts all VMs of a VM Service in a VM Topology
    
    .DESCRIPTION
    Starts all VMs of a VM Service in a VM Topology and all VMs of required Vm Services
    
    .PARAMETER ServiceName
    The name of the VM Service to start
    
    .PARAMETER EnvironmentName
    The name of the VM Environment the VM Service is in
    
    .PARAMETER Service
    VMService object of the VM Service to start
    
    .PARAMETER Environment
    VMEnvironment object of the VM Service to start
    
    .PARAMETER VMTopology
    The VMTopology containing all VM Services and Environments
    
    .PARAMETER Recurse
    Start all required VM Services before starting the current VM Service 
    
    .PARAMETER AdditionalWaitTime
    Additional time to wait after all VMs of a service are started successfully 

    .PARAMETER VMWaitFor
    Item to wait for to determine if a VM is started successfully (IPAddress or Heartbeat)
    
    .EXAMPLE
    Start-VMService -ServiceName Domain -Environment Lab -VMTopology (Get-VMTopology) -Recurse
    
    #>
    [CmdletBinding(DefaultParameterSetName = 'String', SupportsShouldProcess = $true)]
    [OutputType([Bool])]
    param(
        # Name of the VM Service to start
        [Parameter(ParameterSetName = 'String', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Object-String', Mandatory = $true)]     
        [string]
        $ServiceName,
        # Name of the Environment of the service to start
        [Parameter(ParameterSetName = 'String', Mandatory = $true)]
        [Parameter(ParameterSetName = 'String-Object', Mandatory = $true)]
        [string]
        $EnvironmentName,
        # Name of the VM Service to start
        [Parameter(ParameterSetName = 'Object', Mandatory = $true)]
        [Parameter(ParameterSetName = 'String-Object', Mandatory = $true)]     
        [VMService]
        $Service,
        # Name of the Environment of the service to start
        [Parameter(ParameterSetName = 'Object', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Object-String', Mandatory = $true)]     
        [VMEnvironment]
        $Environment,
        # VMTopology
        [Parameter(Mandatory = $true)]
        [VMTopology]
        $VMTopology,
        # Start VM Services recursively
        [Parameter()]
        [switch]
        $Recurse,
        # Additional seconds to wait after VM is started
        [Parameter()]
        [int]
        $AdditionalWaitTime = 20,
        # Wait For
        [Parameter()]
        [String]
        [ValidateSet('IPAddress', 'Heartbeat')]
        $VMWaitFor = 'IPAddress'
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
            Throw ('Could not find any VM for the service ' + $ServiceName + ' in the environment ' + $EnvironmentName)
        }
    }
    Process
    {
        if ($Recurse)
        {
            foreach ($Dependency in $Service.DependsOn )
            {
                Write-Verbose ('Starting required service: ' + $Dependency)
                Start-VMService -ServiceName $Dependency -EnvironmentName $EnvironmentName -VMTopology $VMTopology -Recurse | Out-Null
            }
        }
        foreach ($Node in $Service.VM)
        {
            If ($Node.VM.State -ne 'Running')
            {
                if ($PSCmdlet.ShouldProcess(('Starting VM: ' + $Node.Name)))
                {
                    Start-VM -VM $Node.Vm
                    $State = Wait-VM -VM $Node.vm -For $VMWaitFor -Timeout 120 -Passthru
                    Start-Sleep -Seconds $AdditionalWaitTime
                    If (!($State.State -eq 'Running'))
                    {
                        Throw ('Could not start VM: ' + $Node.Name)
                    }
                }
            }            
        }
    }
    End
    {
        Write-Verbose ('Successfully started VM Service: ' + $ServiceName)
        $true
    }
}