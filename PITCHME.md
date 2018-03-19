# PSHVTag

Helps you manage Hyper-V machines on a host by tags. You can define environments, services and dependencies just by adding a tag line to the VM Notes.

The module will build a consistent VM Topology object from the tags. The topology allows you to start and stop VM Services and all their dependencies. You can also print a graph of the topology or use it to select virtual machines for all other Hyper-V Cmdlets by service or environment.

---

### Getting Started

Install from the PSGallery and Import the module

    Install-Module PSHVTag
    Import-Module PSHVTag

---

### What's next?

- Adding a GUI
- Adding the running state to the VM Services and a method to refresh it
- Adding a function to edit single Tag elements instead of setting the whole Tag string at once.

For more information

- [PSHVTag.readthedocs.io](http://PSHVTag.readthedocs.io)
- [github.com/sasstu/PSHVTag](https://github.com/sasstu/PSHVTag)
- [sasstu.github.io](https://sasstu.github.io)
