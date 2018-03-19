# Get-ClonedObject

Clones object on Binary level
Idea from [http://stackoverflow.com/questions/7468707/deep-copy-a-dictionary-hashtable-in-powershell](http://stackoverflow.com/questions/7468707/deep-copy-a-dictionary-hashtable-in-powershell)
borrowed from [http://stackoverflow.com/questions/8982782/does-anyone-have-a-dependency-graph-and-topological-sorting-code-snippet-for-pow](http://stackoverflow.com/questions/8982782/does-anyone-have-a-dependency-graph-and-topological-sorting-code-snippet-for-pow)

## Common Usage

    $currentEdgeList = [hashtable] (Get-ClonedObject $edgeList)

## Arguments

### -DeepCopyObject

Object to Clone.