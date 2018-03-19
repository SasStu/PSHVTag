# Convert-VMNoteTagsToObject

Converts a Hyper-V VM object including State, Status and Notes to a VMWithTag Object including the custom Tag information

## Common Usage

    Get-VM -Name 'Test1' | Convert-VMNoteTagsToObject

## Arguments

### -VM [Microsoft.HyperV.PowerShell.VirtualMachine]

A Hyper-V VM object including, State, Status and Notes.