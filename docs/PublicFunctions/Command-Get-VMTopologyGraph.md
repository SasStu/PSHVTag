# Get-VMTopologyGraph

This command returns a PSGraph showing the VM Topology

## Common Usage

To create and show a graph of a VM-Topology of the localhost use the following

    Get-VMTopologyGraph -VMTopology (Get-VMTopology) | Export-PSGraph -ShowGraph

![VMTopology](/assets/VMTopology.png)

## Arguments

-VMTopology [VMTopology]

The VM-Topology object to create a graph of.