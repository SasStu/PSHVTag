# Set-VMTag

This command adds or replaces the Tag string in the Notes field of a Hyper-V VM.

## Common Usage

Here are the common ways to use this command.

### Add a Tag to a VM

If the Notes field of the VM does not contain a Tag string already you can add it like this:

    Set-VMTag -VMName DomainController01 -Environment Lab01 -Service Domain -DependsOn Gateway

If you want to replace a Tag just use the following

    Set-VMTag -VMName DomainController01 -Environment Lab01 -Service Domain -DependsOn @('Gateway', 'DHCP') -Force

## Arguments

### -Environment [string[]]

The environment the VM belongs to. It accepts arrays as well as single strings.

### -Service [string[]]

The service the VM provides. It accepts arrays as well as single strings.

### -DependsOn [string[]]

The Service the VM depends on. It accepts arrays as well as single strings.

### -VMName [string[]]

The name of the VM were you want to set the Tag. It accepts arrays as well as single strings.

### -VM [Microsoft.HyperV.PowerShell.VirtualMachine[]]

The VM object were you want to set the Tag. It accepts arrays as well as single strings.

### -Computername [string]

The Hyper-V host containing the VM. It is only used in combination with the `VMName` parameter. The default value is `localhost`.

### -Force

Overwrite an existing tag.