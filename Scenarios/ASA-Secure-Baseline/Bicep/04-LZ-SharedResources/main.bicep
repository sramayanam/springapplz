targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/
@description('User name for admin account on the jump host')
param adminUserName string

@description('Boolean describing whether or not to enable soft delete on Key Vault - set to TRUE for production')
param enableKvSoftDelete bool

@secure()
@description('Virtual machine admin account password')
param jumpHostPassword string

@description('Name of the Key Vault secret that will store the jump host password. Specify this value in the parameters.json file to override this default.')
param jumpHostPasswordSecretName string

@description('Name of the key vault. Specify this value in the parameters.json file to override this default.')
param keyVaultName string

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('Name of the resource group that contains the private DNS zones. Specify this value in the parameters.json file to override this default.')
param privateZonesRgName string

@description('Name of the resource group containing shared resources. Specify this value in the parameters.json file to override this default.')
param sharedRgName string

@description('Name of the resource group that contains the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeRgName string

@description('Name of the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeVnetName string

@description('Name of the subnet that has the jump host. Specify this value in the parameters.json file to override this default.')
param subnetShared string

@description('Name of the support subnet. Specify this value in the parameters.json file to override this default.')
param subnetSupport string

@description('Azure Resource Tags')
param tags object

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string

@description('Name of the jump box. Specify this value in the parameters.json file to override this default.')
param vmName string

@description('SKU size of the jump box. Specify this value in the parameters.json file to override this default.')
param vmSize string

/******************************/
/*     RESOURCES & MODULES    */
/******************************/
resource sharedRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: sharedRgName
  location: location
  tags: tags
}

module keyVault '../Modules/keyVault.bicep' = {
  name: '${timeStamp}-kv'
  scope: resourceGroup(sharedRg.name)
  params: {
    dnsResourceGroupName: privateZonesRgName
    enableSoftDelete: enableKvSoftDelete
    location: location
    name: keyVaultName
    networkResourceGroupName: spokeRgName
    subnetName: subnetSupport
    tags: tags
    targetResourceGroupName: sharedRg.name
    timeStamp: timeStamp
    vnetName: spokeVnetName
  }
}

module vmPasswordSecret '../Modules/keyVaultSecret.bicep' = {
  name: '${timeStamp}-kvSecret'
  scope: resourceGroup(sharedRg.name)
  params: {
    parentKeyVaultName: keyVault.outputs.name
    secretName: jumpHostPasswordSecretName
    secretValue: jumpHostPassword
  }
}

module jumpHost '../Modules/virtualMachine.bicep' = {
  name: '${timeStamp}-jumpHost'
  scope: resourceGroup(sharedRg.name)
  params: {
    adminUserName: adminUserName
    adminPassword: jumpHostPassword
    location: location
    networkResourceGroupName: spokeRgName
    subnetName: subnetShared
    tags: tags
    vmName: vmName
    vmSize: vmSize
    vnetName: spokeVnetName
  }
}
