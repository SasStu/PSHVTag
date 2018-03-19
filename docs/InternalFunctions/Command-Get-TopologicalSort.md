# Get-TopologicalSort

Sorts Keys of a Hashtable containing dependent Keys as Value array as a topology.
Thanks to [http://stackoverflow.com/questions/8982782/does-anyone-have-a-dependency-graph-and-topological-sorting-code-snippet-for-pow](http://stackoverflow.com/questions/8982782/does-anyone-have-a-dependency-graph-and-topological-sorting-code-snippet-for-pow)

## Common Usage

    Get-TopologicalSort -edgeList @{ServiceA=@(ServiceB,ServiceC),ServiceB=@(ServiceC)}

## Arguments

### edgeList [hashtable]

A hashtable containing the edges from the Key to the values.