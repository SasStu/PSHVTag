# Get-VMEnvironment

Creates a (array of) VMEnvironment object(s)

## Common Usage

    Get-VMEnvironment -VM (Get-VMWithTag | Convert-VMNoteTagsToObject)

## Arguments

### -VM [VMWithTag[]]

A (list of) VM object(s) with Tags from which to build the VMEnvironment object