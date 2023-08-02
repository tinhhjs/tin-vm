#!/bin/bash
# Usage: bash create-high-availability-vm-with-sets.sh <Resource Group Name>

RgName=$1

date
# Create a Virtual Network for the VMs
echo '------------------------------------------'
echo 'Creating a Virtual Network for the VMs'
az network vnet create \
    --resource-group $RgName \
    --name bePortalVnet \
    --subnet-name bePortalSubnet 

# Create a Network Security Group
echo '------------------------------------------'
echo 'Creating a Network Security Group'
az network nsg create \
    --resource-group $RgName \
    --name bePortalNSG 
# Create a network security group rule for port 22.
echo '------------------------------------------'
echo 'Creating a SSH rule'
az network nsg rule create \
    --resource-group $RgName \
    --nsg-name bePortalNSG \
    --name hoangtin724NetworkSecurityGroupRuleSSH \
    --protocol tcp \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*'  \
    --destination-address-prefix '*' \
    --destination-port-range 22 \
    --access allow \
    --priority 1000

# Add inbound rule on port 80
echo '------------------------------------------'
echo 'Allowing access on port 80'
az network nsg rule create \
    --resource-group $RgName \
    --nsg-name bePortalNSG \
    --name Allow-80-Inbound \
    --priority 200 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 80 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --description "Allow inbound on port 80."
    
# Create the NIC
for i in `seq 1 3`; do
  echo '------------------------------------------'
  echo 'Creating hoangtin724webNic'$i
  az network nic create \
    --resource-group $RgName \
    --name hoangtin724webNic$i \
    --vnet-name bePortalVnet \
    --subnet bePortalSubnet \
    --network-security-group bePortalNSG
done 

# Create an availability set
echo '------------------------------------------'
echo 'Creating an availability set'
az vm availability-set create -n hoangtin724portalAvailabilitySet -g $RgName

# Create 3 VM's from a template
for i in `seq 1 3`; do
    echo '------------------------------------------'
    echo 'Creating hoangtin724webVM'$i
    az vm create \
        --admin-username hoangtin724 \
        --admin-password Admin@1234567 \
        --resource-group $RgName \
        --name hoangtin724webVM$i \
        --nics hoangtin724webNic$i \
        --image UbuntuLTS \
        --availability-set hoangtin724portalAvailabilitySet \
        --generate-ssh-keys \
        --custom-data cloud-init.txt
done

# Done
echo '--------------------------------------------------------'
echo '             VM Setup Script Completed'
echo '--------------------------------------------------------'
