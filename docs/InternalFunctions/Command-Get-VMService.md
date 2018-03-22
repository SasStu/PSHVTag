# Get-VMService

Creates a (array of) VMService object(s) based on the list of tagged VMs defined by the parameter VM.

## Common Usage

    Get-VMService -VM (Get-VMWithTag | Convert-VMNoteTagsToObject)

## Arguments

### -VM [VMWithTag[]]

A (list of) VM object(s) with Tags from which to build the VM-Environment object