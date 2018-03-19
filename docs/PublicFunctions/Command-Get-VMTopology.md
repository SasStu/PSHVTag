# Get-VMTopology

This command creates the whole VM Topology for all Virtual Machines on a given Hyper-V-Host.

## Common Usage

Here are the common ways to use this command.

### Create a VM Topology

    Get-VMTopology -Computername 'Hyper-V-Host01'

If any of the VM dependencies contains a circle relationship this function will throw an error.

## Arguments

### -Computername

The Hyper-V host which contains the tagged virtual machines to build the topology from. The default value is `localhost`.