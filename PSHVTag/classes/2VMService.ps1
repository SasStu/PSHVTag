class VMService
{
    [string]$Name
    [VMWithTag[]]$VM
    [array]$DependsOn
    VMService ([string]$Name, [VMWithTag[]]$VM, [array]$DependsOn)
    {
        $this.Name = $Name
        $this.VM = $VM
        $this.DependsOn = $DependsOn
    }
}