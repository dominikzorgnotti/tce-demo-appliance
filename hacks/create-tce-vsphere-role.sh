# Creating TCE role for vSphere per https://tanzucommunityedition.io/docs/v0.12/ref-vsphere/
# This assumes you have setup your GOVC environment per https://github.com/vmware/govmomi/tree/master/govc
# Latest: https://gist.github.com/dominikzorgnotti/cf2264945c9316eaa25f196d41eda308

govc role.create role_TCE \
Cns.Searchable \
Datastore.AllocateSpace \
Datastore.Browse \
Datastore.FileManagement \
Global.DisableMethods \
Global.EnableMethods \
Global.Licenses \
Network.Assign \
StorageProfile.View \
Resource.AssignVMToPool \
Sessions.GlobalMessage \
Sessions.ValidateSession \
VApp.Import \
VirtualMachine.Config.AddExistingDisk \
VirtualMachine.Config.AddNewDisk \
VirtualMachine.Config.AddRemoveDevice \
VirtualMachine.Config.AdvancedConfig \
VirtualMachine.Config.CPUCount \
VirtualMachine.Config.Memory \
VirtualMachine.Config.Settings \
VirtualMachine.Config.RawDevice \
VirtualMachine.Config.DiskExtend \
VirtualMachine.Config.EditDevice \
VirtualMachine.Config.RemoveDisk \
VirtualMachine.Config.ChangeTracking \
VirtualMachine.Inventory.CreateFromExisting \
VirtualMachine.Inventory.Delete \
VirtualMachine.Interact.PowerOff \
VirtualMachine.Interact.PowerOn \
VirtualMachine.Provisioning.GetVmFiles \
VirtualMachine.Provisioning.DeployTemplate \
VirtualMachine.Provisioning.DiskRandomRead \
VirtualMachine.State.CreateSnapshot \
VirtualMachine.State.RemoveSnapshot
