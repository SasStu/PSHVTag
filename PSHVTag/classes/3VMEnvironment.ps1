class VMEnvironment
{
    [string]$Name
    [VMService[]]$Service
    [VMWithTag[]] $VM
    [System.Collections.ArrayList]$EdgeList
    [Array]$Order
    
    VMEnvironment ([string] $Name, [VMService[]]$Service, [VMWithTag[]] $VM, [System.Collections.ArrayList]$EdgeList, [Array]$Order)
    {
        $this.Name = $Name
        $this.Service = $Service
        $this.VM = $VM
        $this.EdgeList = $EdgeList
        $this.Order = $Order
    }
}