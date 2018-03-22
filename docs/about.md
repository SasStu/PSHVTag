# What is PSHVTag

I have written PSHVTag because I am using many Hyper-V virtual machines in my lab environments. And I have to start and stop the different labs very often. The VM usually needs some time to fully startup before I can start the next one. For example my Gateway VM has to be up and running before I can start the Domain Controller behind it. And the DC has to be up and running before I can start the ConfigMgr server etc..

With this module it is very easy to start a VM Service like SCCM with all its dependencies with just a simple PowerShell command.
You can also use the VM Topology object to select virtual machines and use them with any other Hyper-V PowerShell command like Export-VM.

While creating the module I thought it would be nice to have a graph of my lab environments. Consequently, I added a function based on the [PSGraph](https://github.com/KevinMarquette/PSGraph) module to it, which allows you to map your environments.

![VMTopology](/images/VMTopology.png)

Authored by Sascha Stumpler
