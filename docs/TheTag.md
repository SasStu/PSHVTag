# The Tag

The Tag used to create the VM Topology consists of three elements and is stored as a single line in the notes field of a Hyper-V VM. __Only one tag line is allowed per VM__.

## Elements

### Environment

This element defines the VM Environments a virtual machine belongs to. One VM has to belong to one but __can belong to multiple environments__. But it has to provide the __same services in all environments__ and it __depends on the same services in all environments__.

### Service

The service element defines the services provided by the VM for the environments it belongs to. A virtual machine can provide one or more services.

### DependsOn

The DependsOn element includes all services a VM requires to be up in running before itself can fully operate. For example an Azure AD Connect server depends on the Domain an internet access.

## Syntax

A tag line looks like the example below. Multiple instances of an element are separated by a comma.

\<Env>`Environment1,Environment2`\</Env>\<Service>`Service1,Service2`\</Service>\<DependsOn>`RequiredService1,RequiredService2`\</DependsOn>

You can create a tag also by using the Set-VMTag command.