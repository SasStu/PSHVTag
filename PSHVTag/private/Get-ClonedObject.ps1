
function Get-ClonedObject
{
    <#
    .SYNOPSIS
    Clones object on Binary level
    
    .DESCRIPTION
    Clones object on Binary level
    
    .PARAMETER DeepCopyObject
    Object to Clone
    
    .EXAMPLE
    $currentEdgeList = [hashtable] (Get-ClonedObject $edgeList)
    
    .NOTES
    Idea from http://stackoverflow.com/questions/7468707/deep-copy-a-dictionary-hashtable-in-powershell 
    borrowed from http://stackoverflow.com/questions/8982782/does-anyone-have-a-dependency-graph-and-topological-sorting-code-snippet-for-pow
    #>
    param($DeepCopyObject)
    $memStream = new-object IO.MemoryStream
    $formatter = new-object Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $formatter.Serialize($memStream, $DeepCopyObject)
    $memStream.Position = 0
    $formatter.Deserialize($memStream)
}