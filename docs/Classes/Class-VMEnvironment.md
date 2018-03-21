# VM-Environment

A environment containing one ore more virtual machines providing services.

## Properties

### Name [string]

The Name of the VM-Environment.

### EdgeList [System.Collections.ArrayList]

A ArrayList with the services provided in this environment as keys and the required services as values.

### Order [Array]

The order of the services is build from the EdgeList. It defines the start order of all services within the environment. __It can only be build if there is no cycle in the relationships between the services__.

### VM [VMWithTag[]]

All [tagged virtual machines](VMwithtag.md) in the environment.

### Service [VMService[]]

An array of the VM-Services provided by the virtual machines in the environment. A VM Service is a [custom PowerShell class](VMService.md).