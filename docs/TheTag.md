# The Tag

The Tag used to create the VM-Topology consists of three elements and is stored as a single line in the notes field of a Hyper-V VM. __Only one tag line is allowed per VM__.

## Elements

### Environment

This tag element defines the VM-Environment the virtual machine belongs to. One VM __has to belong to one environment and can belong to multiple environments__. But it has to provide the __same services in all environments__ and it __has to depend on the same services in all environments__.

### Service

The service element defines the services provided by the VM for the environments it belongs to. A virtual machine can provide one or more services.

### DependsOn

The DependsOn element includes all services a VM requires to be up in running before it can fully operate. For example, an Azure AD Connect server depends on the domain and internet access.

## Syntax

A tag line looks like the example below. Multiple instances of an element are separated by a comma.

    <pre><code>&lt;Env&gt;Environment1,Environment2&lt;/Env&gt;&lt;Service&gt;Service1,Service2&lt;/Service&gt;&lt;DependsOn&gt;RequiredService1,RequiredService2&lt;/DependsOn&gt;</code></pre>

You can create a tag by using the [Set-VMTag](PublicFunctions/Command-Set-VMTag.md) command.