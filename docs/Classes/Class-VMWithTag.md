# VMWithTag

A custom PowerShell class describing a Hyper-V virtual machine object including the information provided by the tag.

## Properties

### Name [String]

The name of the virtual machine.

### VM [Microsoft.HyperV.PowerShell.VirtualMachine]

The Hyper-V VM object.

### Environment [String[]]

The VM-Environments the VM belongs to.

### Service [String[]]

The VM-Service the VM belongs to.

### DependsOn [String[]]

The VM-Service the VM depends on.