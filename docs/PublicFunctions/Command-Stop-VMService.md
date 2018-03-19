# Stop-VMService

This command stops virtual machines based on the service defined in the tag.

## Common Usage

To stop a service and all required services after it the following command can be used

    Stop-VMService -ServiceName Domain -EnvironmentName LAB01 -VMTopology (Get-VMTopology) -Recurse

## Arguments

### -ServiceName [string]

The name of the VM Service to stop.

### -EnvironmentName [string]

The name of the VM Environment the VM Service is in.

### -Service [VMService]

VMService object of the VM Service to stop

### -Environment [VMEnvironment]

VMEnvironment object of the VM Service to stop

### -VMTopology [VMTopology]

The VMTopology containing all VM Services and Environments of a host.

### -Recurse [switch]

Stop all required VM Services after stopping the current VM Service.

### -Force [switch]

Force stopping of all virtual machines.
