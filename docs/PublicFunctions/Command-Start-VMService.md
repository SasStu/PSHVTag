# Start-VMService

This command starts virtual machines based on the service defined in the tag.

## Common Usage

To start a service and all required services before the following command can be used

    Start-VMService -ServiceName Domain -EnvironmentName LAB01 -VMTopology (Get-VMTopology) -Recurse

## Arguments

### -ServiceName [string]

The name of the VM Service to start.

### -EnvironmentName [string]

The name of the VM Environment the VM Service is in.

### -Service [VMService]

VMService object of the VM Service to start

### -Environment [VMEnvironment]

VM-Environment object of the VM Service to start

### -VMTopology [VMTopology]

The VMTopology containing all VM Services and Environments of a host.

### -Recurse [switch]

Start all required VM Services before starting the current VM Service.

### -AdditionalWaitTime [integer]

Additional seconds to wait after all VMs of a service are started successfully and assumed running. The default value is `20`.

### -VMWaitFor [string] (IPAddress, Heartbeat)

The condition to wait for before a virtual machine is assumed running. The default value is `IPAddress`.