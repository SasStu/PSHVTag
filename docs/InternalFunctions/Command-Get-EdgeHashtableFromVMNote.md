# Get-EdgeHashtableFromVMNote

Creates a hashtable with KeyProperty as Key and Value property as (an array of) Value(s)

## Common Usage

    Get-EdgeHashtableFromVMNote -VM $VM -KeyProperty Service -ValueProperty DependsOn

## Arguments

### -VM [VMWithTag[]]

A VMWithTag object

### -KeyProperty [string]

The property of the VM object which should be used as Key in the hashtable to create.

### -ValueProperty [string]

The property of the VM object to use as value of the hashtable to create.