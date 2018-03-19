# Quick start

## Installing PSHVTag

    # Install PSHVTag from the PowerShell Gallery
    Find-Module PSHVTag | Install-Module

    #Import Module
    Import-Module PSHVTag

## Creating your first VM Topology

    $VMTopology = Get-VMTopology -Computername 'Hyper-V-Host01'

## Setting a VM-Tag

    Set-VMTag -VMName DomainController01 -Environment Lab01 -Service Domain -DependsOn Gateway

## Starting a VM-Service with its dependencies

    Start-VMService -ServiceName Domain -EnvironmentName LAB01 -VMTopology (Get-VMTopology) -Recurse