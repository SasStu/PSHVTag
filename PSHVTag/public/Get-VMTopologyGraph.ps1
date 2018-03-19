#Requires -Modules PSGraph
function Get-VMTopologyGraph
{
    <#
    .SYNOPSIS
    Exports a Topological Graph 
    
    .DESCRIPTION
    Exports a Topological Graph as JPEG and opens it
    
    .PARAMETER VMTopology
    A VM Topology object
    
    .EXAMPLE
    Get-VMTopology -VMTopology (Get-VMTopology)

    #>
    [CmdletBinding()]
    param(
        # VMTopology to show
        [Parameter(Mandatory = $true)]
        [VMTopology]
        $VMTopology
    )
    Import-Module PSGraph
    $Graph = graph "myGraph" {
        node -Default @{shape = 'box'}
        $subGraphID = 0
        ForEach ($Environment in $VMTopology.Environment)
        {
            subgraph $subGraphID -Attributes @{label = $Environment.Name} {
                Foreach ($Service in $Environment.Service)
                {
                    #Node ($Environment.Name + '|' + $Service.Name) @{label = $Service.Name}
                    Record -Name ($Environment.Name + '|' + $Service.Name) -Rows ((($VMTopology.Environment | Where-Object -Property Name -Value $Environment.Name -EQ).Service | Where-Object -Property Name -Value $Service.Name -EQ).VM.Name) -Label $Service.Name
                    ForEach ($DependsOn in $Service.DependsOn)
                    {
                        If ($DependsOn -ne '')
                        {
                            edge -from ($Environment.Name + '|' + $Service.Name)  -to ($Environment.Name + '|' + $DependsOn)
                        }
                    }      
                }
            }
            $subGraphID = $subGraphID + 1
        }
    } 
    $Graph
}