# VM-Service

A service provided by one or more VMs on the host.

## Properties

### Name [string]

The name of the service.

### VM [VMWithTag[]]

An array of all [tagged virtual machines](Class-VMWithTag.md) providing this service in this environment.

### DependsOn [array]

An array of all VM-Services required by one or more virtual machines within the service.