# List available snapshots for a VM AD-contoso.com (Note: * current snapshot)
vboxmanage snapshot AD-contoso.com list
#  Restoring to 20160712 (UUID: 67e8772f-c73c-4273-8812-7f1618561827)
vboxmanage snapshot AD-contoso.com restore 67e8772f-c73c-4273-8812-7f1618561827
#  Deleting 20160728 (UUID: 092431ba-f027-416a-8da3-4451307e01c8)
vboxmanage snapshot AD-contoso.com delete 092431ba-f027-416a-8da3-4451307e01c8
# Rename a VM
vboxmanage snapshot AD-contoso.com edit 46cfa701-3ac2-41cf-85dd-7b107d5f5650  --name 20161114
