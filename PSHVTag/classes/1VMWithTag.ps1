# VM with Tag
class VMWithTag
{
    # Name of the VM
    [string] $Name
    # VM ID 
    [Microsoft.HyperV.PowerShell.VirtualMachine]$VM
    # Environment
    [String[]] $Environment
    # Service provided by VM
    [String[]] $Service
    # DependsOn Services
    [String[]] $DependsOn

    # Constructor
    VMWithTag ([string] $name, [Microsoft.HyperV.PowerShell.VirtualMachine]$VM, [String[]]$Environment, [String[]] $Service, [String[]] $DependsOn)
    {
        $this.Name = $name
        $this.VM = $VM
        $this.Environment = $Environment
        $this.Service = $Service
        $this.DependsOn = $DependsOn
    }
}