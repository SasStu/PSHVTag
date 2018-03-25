# VM-Environment

An environment containing one ore more virtual machines providing services.

## Properties

### Name [string]

The Name of the VM-Environment.

### EdgeList [System.Collections.ArrayList]

An ArrayList with the services provided in this environment as keys and the required services as values.

### Order [Array]

The order of the services built from the EdgeList. It defines the start order of all services within the environment. __It can be built if there is no cycle in the relationships between the services__.

### VM [VMWithTag[]]

All [tagged virtual machines](Class-VMWithTag.md) in the environment.

### Service [VMService[]]

An array of the VM-Services provided by the virtual machines in the environment. A VM Service is a [custom PowerShell class](Class-VMService.md).