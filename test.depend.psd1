@{ 
    PSDependOptions = @{ 
        Target    = '$DependencyPath/_build-cache/'
        AddToPath = $true
    }
    # Add the *exact versions* of any dependencies of your module...
    # EG:
    # IISAdministration   = '1.1.0.0'
    PSGraph         = 'latest'
    <#Hyper_V = @{
            DependencyType = 'Command'
            Source = Import-Module Hyper-V
        }
        #>
}