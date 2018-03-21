Describe "Basic function unit tests" -Tags Build {
    BeforeAll {
        Unload-SUT
        Import-Module ($global:SUTPath)
    }
    InModuleScope -ModuleName $env:BHProjectName {
        function Get-MockVMFromFile ()
        {
            [CmdletBinding()]
            param(
                # Specifies a path to one or more locations.
                [Parameter(Mandatory = $true,
                    Position = 0,
                    ParameterSetName = "ParameterSetName",
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = "Path to one or more locations.")]
                [ValidateNotNullOrEmpty()]
                [string[]]
                $File
            )
    
            $VM = Get-Content $File -Raw | ConvertFrom-Json
            $VMMock = New-MockObject -Type 'Microsoft.Hyperv.PowerShell.VirtualMachine'
            foreach ($property in ($VM | Get-Member -MemberType NoteProperty).Name)
            { 
                $addmembersplat = @{
                    MemberType = [System.Management.Automation.PSMemberTypes]::NoteProperty
                    Name       = $property
                    value      = $vm.$property
                    Force      = $true   
                }
                $VMMock | Add-Member @addmembersplat -ErrorAction 0
            }
            $VMMock
        }

        class MockVM
        {
            [string]$Name
            $VMMock
            [string[]]$Environment
            [string[]]$Service
            [string[]]$DependsOn
            MockVM ([string]$Name, $VMMock, [string[]]$Environment, [string[]]$Service, [string[]]$DependsOn)
            {
                $this.Name = $name
                $this.VMMock = $VMMock
                $this.Environment = $Environment
                $this.Service = $Service
                $this.DependsOn = $DependsOn
            }
        }

        $DC01 = [MockVM]::new('DC01', (Get-MockVMFromFile -File "$PSScriptRoot\test.data\DC01.json"), 'LAB01', 'Domain', 'Gateway')
        $Gateway01 = [MockVM]::new('Gateway', (Get-MockVMFromFile -File "$PSScriptRoot\test.data\Gateway01.json"), @('LAB01', 'LAB02'), 'Gateway', $null)
        $SCCM01 = [MockVM]::new('SCCM', (Get-MockVMFromFile -File "$PSScriptRoot\test.data\SCCM01.json"), @('LAB01'), @('SCCM'), @('Domain', 'FileServer'))
        $FileServer01 = [MockVM]::new('FileServer', (Get-MockVMFromFile -File "$PSScriptRoot\test.data\FileServer01.json"), @('LAB01'), @('FileServer'), @('Domain'))
        $FileServer02 = [MockVM]::new('FileServer', (Get-MockVMFromFile -File "$PSScriptRoot\test.data\FileServer02.json"), @('LAB01'), @('FileServer'), @('Domain'))
        $FileServer03 = [MockVM]::new('FileServer', (Get-MockVMFromFile -File "$PSScriptRoot\test.data\FileServer03.json"), @('LAB01'), @('FileServer'), @('Domain', 'Dummy'))
        $FileServer04 = [MockVM]::new('FileServer', (Get-MockVMFromFile -File "$PSScriptRoot\test.data\FileServer04.json"), @('LAB01'), @('FileServer'), @('Domain'))
        $FileServer05 = [MockVM]::new('FileServer', (Get-MockVMFromFile -File "$PSScriptRoot\test.data\FileServer05.json"), @('LAB01'), @('FileServer'), @('Domain'))
        $MockVMs = @($DC01, $Gateway01, $SCCM01, $FileServer01)
        $Services = @{'Domain' = @('Gateway'); 'Gateway' = @(); 'SCCM' = @('Domain', 'FileServer'); 'FileServer' = @('Domain') }
        $Environment = @{'LAB01' = @('Domain', 'Gateway', 'SCCM', 'FileServer'); 'LAB02' = @('Gateway') }
        $Graph = Get-Content -Path "$PSScriptRoot\test.data\graph.json" -Raw | ConvertFrom-Json 
    
        $TaggedVM = @()
        
        Mock -CommandName Get-VM -MockWith {return ($MockVMs | % {$_.VMMock})} -Verifiable
        Mock -CommandName Start-Sleep
        Mock -CommandName Start-Vm -Verifiable
        # Test Convert-VMNoteTagsToObject

        Describe -Name 'Convert-VMNoteTagsToObject' {
            foreach ($MockVM in $MockVMs)
            {
                it -name "should return $($MockVM.Name) VMwitHTagObject" {
                    $VMWithTag = Convert-VMNoteTagsToObject -VM $MockVM.VMMock
                    $VMWithTag.Environment | Should -Be $MockVM.Environment
                    $VMWithTag.Service | Should -Be $MockVM.Service
                    $VMWithTag.DependsOn | Should -Be $MockVM.DependsOn
                }
            }
        }

        foreach ($MockVM in $MockVMs)
        {
            [VmWithTag[]]$TaggedVM += (Convert-VMNoteTagsToObject -VM $MockVM.VMMock)
        }
        #Test Get-EdgeHashtableFromVMNote
        Describe -Name 'Get-EdgeHashtableFromVMNote' {

            it -name "should return Service DependsOn EdgeList" {
                $EdgeList = Get-EdgeHashtableFromVMNote -VM $TaggedVM -KeyProperty 'Service' -ValueProperty 'DependsOn'
                $EdgeList.Keys | Sort-Object | Should -Be ($Services.Keys | Sort-Object)
                foreach ($Key in $EdgeList.Keys)
                {
                    $EdgeList.Item($Key) | Should -Be $Services.Item($Key)
                }
            }
    
            it -name "should return Environment Service EdgeList" {
                $EdgeList = Get-EdgeHashtableFromVMNote -VM $TaggedVM -KeyProperty 'Environment' -ValueProperty 'Service'
                $EdgeList.Keys | Sort-Object | Should -Be ($Environment.Keys | Sort-Object)
                foreach ($Key in $EdgeList.Keys)
                {
                    $EdgeList.Item($Key) | Should -Be $Environment.Item($Key)
                }
            }
        }

        $VMService = Get-VMService -VM $TaggedVM
        Describe -Name 'Get-VMService' {
            it -name "should return a VMService object" {
                ($VMService | Where-Object -Property Name -EQ 'Gateway').VM.Name | Should -Be 'DefGateway01'
                ($VMService | Where-Object -Property Name -EQ 'Gateway').DependsOn | Should -Be $null
                ($VMService | Where-Object -Property Name -EQ 'Domain').VM.Name | Should -Be 'DomainController01'
                ($VMService | Where-Object -Property Name -EQ 'Domain').DependsOn | Should -Be 'Gateway'
                ($VMService | Where-Object -Property Name -EQ 'SCCM').VM.Name | Should -Be 'SCCM01'
                ($VMService | Where-Object -Property Name -EQ 'SCCM').DependsOn | Should -Be @('Domain', 'FileServer')
                ($VMService | Where-Object -Property Name -EQ 'FileServer').VM.Name | Should -Be 'FileServer01'
                ($VMService | Where-Object -Property Name -EQ 'FileServer').DependsOn | Should -Be 'Domain'
            }
        }

        $VMEnvironment = Get-VMEnvironment -VM $TaggedVM
        Describe -Name 'Get-VMEnvironment' {
            it -name "should return a VMEnvironment object" {
                $VMEnvironment.Name | Should -be @('LAB01', 'LAB02')
                ($VMEnvironment | Where-Object -Property Name -eq 'LAB01').Order | Should -Be @('Gateway', 'Domain', 'FileServer', 'SCCM')
                ($VMEnvironment | Where-Object -Property Name -eq 'LAB02').Order | Should -Be @('Gateway')
            }
            $BadTaggedVM = $TaggedVM + (Convert-VMNoteTagsToObject -VM $FileServer02.VMMock)
            it -name "should throw circle error" {
                {Get-VMEnvironment -VM $BadTaggedVM} | Should -Throw
            }
            $BadTaggedVM = $TaggedVM + (Convert-VMNoteTagsToObject -VM $FileServer03.VMMock)
            it -name "should throw missing service error" {
                {Get-VMEnvironment -VM $BadTaggedVM} | Should -Throw
            }
        }
        Describe -Name 'Get-VMTopology' {
            it -name "should return a VMTopology" {
                $VMTopology = Get-VMTopology
                Assert-MockCalled -CommandName 'Get-VM' -Times 1 -ParameterFilter {$Computername -eq 'localhost'} -Scope It
                $VMTopology.Computername | Should -Be 'localhost' 
                $VMTopology.VM.Name | Should -Be @('DomainController01', 'DefGateway01', 'SCCM01', 'FileServer01')
                $VMTopology.Environment.Name | Should -Be @('LAB01', 'LAB02')
            }
        }
        Describe -Name 'Start-VMService' {
            $VMTopology = Get-VMTopology
            it -name "should start the VMService FileServer by ServiceName and Environmentname" {
                Mock -CommandName Wait-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Running'}} -ParameterFilter {$VM -eq $FileServer01.VMMock}
                Start-VMService -ServiceName 'FileServer' -EnvironmentName 'LAB01' -VMTopology $VMTopology
                Assert-MockCalled -CommandName Start-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer01.VMMock}
                Assert-MockCalled -CommandName Wait-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer01.VMMock}
            }
        
            it -name "should start the VMService Gateway, Domain, FileService and SCCM by ServiceObject and EnvironmentObject" {
                Mock -CommandName Wait-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Running'}}
                Start-VMService -Service (($VMTopology.Environment | Where-Object -Property Name -EQ 'LAB01').Service | Where-Object -Property Name -EQ 'SCCM') -Environment ($VMTopology.Environment | Where-Object -Property Name -EQ 'LAB01') -VMTopology $VMTopology -Recurse
                Assert-MockCalled -CommandName Start-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $Gateway01.VMMock}
                Assert-MockCalled -CommandName Wait-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $Gateway01.VMMock}
                Assert-MockCalled -CommandName Start-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $DC01.VMMock}
                Assert-MockCalled -CommandName Wait-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $DC01.VMMock}
                Assert-MockCalled -CommandName Start-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer01.VMMock}
                Assert-MockCalled -CommandName Wait-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer01.VMMock}
                Assert-MockCalled -CommandName Start-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $SCCM01.VMMock}
                Assert-MockCalled -CommandName Wait-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $SCCM01.VMMock}
            }
            it -name "should start the VMService Gateway and throw and error when trying to start Domain by ServiceName and EnvironmentObject" {
                Mock -CommandName Wait-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Running'}} -ParameterFilter {$VM -ne $DC01.VMMock}
                Mock -CommandName Wait-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Off'}} -ParameterFilter {$VM -eq $DC01.VMMock}
                {Start-VMService -ServiceName 'Domain' -Environment ($VMTopology.Environment | Where-Object -Property Name -EQ 'LAB01') -VMTopology $VMTopology -Recurse} | Should -Throw
                Assert-MockCalled -CommandName Start-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $Gateway01.VMMock}
                Assert-MockCalled -CommandName Wait-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $Gateway01.VMMock}
                Assert-MockCalled -CommandName Start-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $DC01.VMMock}
                Assert-MockCalled -CommandName Wait-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $DC01.VMMock}
            }
            it -name "should start the VMService Gateway and Domain by ServiceObject and EnvironmentName" {
                Mock -CommandName Wait-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Running'}} 
                Mock -CommandName Wait-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Running'}} -ParameterFilter {$VM -eq $DC01.VMMock}
                Start-VMService -Service (($VMTopology.Environment | Where-Object -Property Name -EQ 'LAB01').Service | Where-Object -Property Name -EQ 'Domain') -EnvironmentName 'LAB01' -VMTopology $VMTopology -Recurse 
                Assert-MockCalled -CommandName Start-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $Gateway01.VMMock}
                Assert-MockCalled -CommandName Wait-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $Gateway01.VMMock}
                Assert-MockCalled -CommandName Start-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $DC01.VMMock}
                Assert-MockCalled -CommandName Wait-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $DC01.VMMock}
            }
            it -name "should throw no VMs for the not existing Service by ServiceName" {
                {Start-VMService -ServiceName 'Dummy' -EnvironmentName 'LAB01' -VMTopology $VMTopology -Recurse} | Should -Throw
            }
        }
        Describe -Name 'Stop-VMService' {
            $VMTopology = Get-VMTopology
            it -name "should stop the VMService FileServer by ServiceName and Environmentname" {
                Mock -CommandName Stop-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Off'}} -ParameterFilter {$VM -eq $FileServer01.VMMock}
                Stop-VMService -ServiceName 'FileServer' -EnvironmentName 'LAB01' -VMTopology $VMTopology
                Assert-MockCalled -CommandName Stop-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer01.VMMock}
            }
            it -name "should stop the VMService Gateway, Domain, FileService and SCCM by ServiceObject and EnvironmentObject" {
                Mock -CommandName Stop-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Off'}}
                Stop-VMService -Service (($VMTopology.Environment | Where-Object -Property Name -EQ 'LAB01').Service | Where-Object -Property Name -EQ 'SCCM') -Environment ($VMTopology.Environment | Where-Object -Property Name -EQ 'LAB01') -VMTopology $VMTopology -Recurse
                Assert-MockCalled -CommandName Stop-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $Gateway01.VMMock}
                Assert-MockCalled -CommandName Stop-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $DC01.VMMock}
                Assert-MockCalled -CommandName Stop-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer01.VMMock}
                Assert-MockCalled -CommandName Stop-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $SCCM01.VMMock}
                
            }
            it -name "should stop the VMService Gateway and throw and error when trying to start Domain by ServiceName and EnvironmentObject" {
                Mock -CommandName Stop-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Running'}} -ParameterFilter {$VM -eq $DC01.VMMock}
                {Stop-VMService -ServiceName 'Domain' -Environment ($VMTopology.Environment | Where-Object -Property Name -EQ 'LAB01') -VMTopology $VMTopology -Recurse} | Should -Throw
                Assert-MockCalled -CommandName Stop-VM -Times 1 -Scope It -ParameterFilter {$VM -eq $DC01.VMMock}
            }
            it -name "should stop the VMService SCCM, Gateway and Domain by ServiceObject and EnvironmentName" {
                Mock -CommandName Stop-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Off'}}
                Mock -CommandName Stop-VM -Verifiable -MockWith {return [PSCustomObject]@{State = 'Off'}} -ParameterFilter {$VM -eq $DC01.VMMock}
                Stop-VMService -Service (($VMTopology.Environment | Where-Object -Property Name -EQ 'LAB01').Service | Where-Object -Property Name -EQ 'SCCM') -EnvironmentName 'LAB01' -VMTopology $VMTopology -Recurse -Force
                Assert-MockCalled -CommandName Stop-VM -Times 1 -Scope it -ParameterFilter {$VM -eq $Gateway01.VMMock}
                Assert-MockCalled -CommandName Stop-VM -Times 1 -Scope it -ParameterFilter {$VM -eq $SCCM01.VMMock}
                Assert-MockCalled -CommandName Stop-VM -Times 1 -Scope it -ParameterFilter {$VM -eq $FileServer01.VMMock}
                Assert-MockCalled -CommandName Stop-VM -Times 1 -Scope it -ParameterFilter {$VM -eq $DC01.VMMock}
            }
            it -name "should throw not existing Service by ServiceName" {
                {Stop-VMService -ServiceName 'Dummy' -EnvironmentName 'LAB01' -VMTopology $VMTopology -Recurse} | Should -Throw
            }
        }
        Describe -Name 'Get-VMTopologyGraph' {
            $VMTopology = Get-VMTopology
            it -name "should return a graph of the VMTopology" {
                $TopologyGraph = Get-VMTopologyGraph -VMTopology $VMTopology
                $TopologyGraph | Should -Be $graph
            }    
        }
        Describe -Name 'Set-VMTag' {
            # Set-VMTag
            # VMName, Env, Serv, Depends
            it -name "should set the VMTag" {
                Mock -CommandName Get-VM -MockWith {return $FileServer04.VMMock} -Verifiable
                Mock -CommandName Set-VM -Verifiable
                $Result = Set-VMTag -VMName 'FileServer04' -Environment @('Pester1', 'Pester2') -Service 'FileServer' -DependsOn 'Domain' 
                (Compare-Object -ReferenceObject ([pscustomobject]@{Success = @('FileServer04'); Error = @()}) -DifferenceObject $Result -Property Success, Error) | Should -BeNullOrEmpty
                Assert-MockCalled -CommandName Get-VM -Scope It -Times 1
                Assert-MockCalled -CommandName Set-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer04.VMMock -and $Notes -eq ('Test' + "`r`n" + '<Env>Pester1,Pester2</Env><Service>FileServer</Service><DependsOn>Domain</DependsOn>' + "`r`n")}  
            }
            # VMName, Env, Serv, Depends Force
            it -name "should replace the VMTag" {
                Mock -CommandName Get-VM -MockWith {return $FileServer01.VMMock} -Verifiable
                Mock -CommandName Set-VM -Verifiable
                $Result = Set-VMTag -VMName 'FileServer01' -Environment 'Pester1' -Service @('FileServer', 'DHCP') -DependsOn 'Domain' -Force
                (Compare-Object -ReferenceObject ([pscustomobject]@{Success = @('FileServer01'); Error = @()}) -DifferenceObject $Result -Property Success, Error) | Should -BeNullOrEmpty
                Assert-MockCalled -CommandName Get-VM -Scope It -Times 1
                Assert-MockCalled -CommandName Set-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer01.VMMock -and $Notes -eq ('<Env>Pester1</Env><Service>FileServer,DHCP</Service><DependsOn>Domain</DependsOn>')}  
            }
            #set on empty Notes
            it -name "should set the VMTag on multiple VM objects (overwrite and empty Notes)" {
                Mock -CommandName Set-VM -Verifiable
                $Result = Set-VMTag -VM @($FileServer01.VMMock, $FileServer05.VMMock) -Environment 'Pester1' -Service 'FileServer' -DependsOn @('Domain', 'DHCP') -Force
                (Compare-Object -ReferenceObject ([pscustomobject]@{Success = @('FileServer01', 'FileServer05'); Error = @()}) -DifferenceObject $Result -Property Success, Error) | Should -BeNullOrEmpty
                Assert-MockCalled -CommandName Set-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer01.VMMock -and $Notes -eq ('<Env>Pester1</Env><Service>FileServer</Service><DependsOn>Domain,DHCP</DependsOn>')}
                Assert-MockCalled -CommandName Set-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer05.VMMock -and $Notes -eq ('<Env>Pester1</Env><Service>FileServer</Service><DependsOn>Domain,DHCP</DependsOn>' + "`r`n")}  
            }    
            #set on empty Notes
            it -name "should set the VMTag on multiple VM objects (overwrite and empty Notes)" {
                Mock -CommandName Set-VM -Verifiable -MockWith {return Throw}
                $Result = Set-VMTag -VM @($FileServer01.VMMock, $FileServer05.VMMock) -Environment 'Pester1' -Service 'FileServer' -DependsOn @('Domain', 'DHCP') -Force
                (Compare-Object -ReferenceObject ([pscustomobject]@{Success = @(); Error = @('FileServer01', 'FileServer05')}) -DifferenceObject $Result -Property Success, Error) | Should -BeNullOrEmpty
                Assert-MockCalled -CommandName Set-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer01.VMMock -and $Notes -eq ('<Env>Pester1</Env><Service>FileServer</Service><DependsOn>Domain,DHCP</DependsOn>')}
                Assert-MockCalled -CommandName Set-VM -Scope It -Times 1 -ParameterFilter {$VM -eq $FileServer05.VMMock -and $Notes -eq ('<Env>Pester1</Env><Service>FileServer</Service><DependsOn>Domain,DHCP</DependsOn>' + "`r`n")}  
            }   
            # VMName, Env, Serv, Depends Force
            it -name "should replace the VMTag" {
                Mock -CommandName Get-VM -MockWith {return Throw} -Verifiable
                {Set-VMTag -VMName 'FileServer01' -Environment 'Pester1' -Service @('FileServer', 'DHCP') -DependsOn 'Domain' -Force} | Should -Throw
                Assert-MockCalled -CommandName Get-VM -Scope It -Times 1
            } 
            # VMName, Env, Serv, Depends Force
            it -name "should replace the VMTag" {
                Mock -CommandName Get-VM -MockWith {return $FileServer01.VMMock} -Verifiable
                $Result = Set-VMTag -VMName 'FileServer01' -Environment 'Pester1' -Service @('FileServer', 'DHCP') -DependsOn 'Domain'
                (Compare-Object -ReferenceObject ([pscustomobject]@{Success = @(); Error = @('FileServer01')}) -DifferenceObject $Result -Property Success, Error) | Should -BeNullOrEmpty
                Assert-MockCalled -CommandName Get-VM -Scope It -Times 1
            } 
        }
    }
}

AfterAll {
    Unload-SUT
}
