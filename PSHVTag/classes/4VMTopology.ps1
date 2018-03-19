class VMTopology
{
    [string] $Computername
    [VMWithTag[]] $VM
    [VMEnvironment[]] $Environment
    # Constructor
    VMTopology ([string] $Computername, [VMWithTag[]] $VM, [VMEnvironment[]] $Environment)
    {
        $this.Computername = $Computername
        $this.VM = $VM
        $this.Environment = $Environment
    }
}