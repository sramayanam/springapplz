targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/
@description('IP CIDR Block for the App Gateway Subnet')
param appGwSubnetPrefix string

@description('Name of the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetName string

@description('Name of the RG that has the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetRgName string

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('The Azure AD Service Principal ID of the Azure Spring Cloud Resource Provider - this value varies by tenant - use the command "az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv" to get the value specific to your tenant')
param principalId string

@description('Name of the resource group that contains the private DNS zones. Specify this value in the parameters.json file to override this default.')
param privateZonesRgName string

@description('IP CIDR Block for the Shared Subnet')
param sharedSubnetPrefix string

@description('Network Security Group name for the Application Gateway subnet should you chose to deploy an AppGW. Specify this value in the parameters.json file to override this default.')
param snetAppGwNsg string

@description('Network Security Group name for the ASA app subnet. Specify this value in the parameters.json file to override this default.')
param snetAppNsg string

@description('Network Security Group name for the ASA runtime subnet. Specify this value in the parameters.json file to override this default.')
param snetRuntimeNsg string

@description('Network Security Group name for the shared subnet. Specify this value in the parameters.json file to override this default.')
param snetSharedNsg string

@description('Network Security Group name for the support subnet. Specify this value in the parameters.json file to override this default.')
param snetSupportNsg string

@description('Name of the Spring Apps Runtime subnet. Specify this value in the parameters.json file to override this default.')
param snetRuntimeName string

@description('Name of the Spring Apps subnet. Specify this value in the parameters.json file to override this default.')
param snetAppName string

@description('Name of the Support subnet. Specify this value in the parameters.json file to override this default.')
param snetSupportName string

@description('Name of the Shared subnet. Specify this value in the parameters.json file to override this default.')
param snetSharedName string

@description('Name of the App Gateway subnet. Specify this value in the parameters.json file to override this default.')
param snetAppGwName string

@description('Name of the resource group that contains the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeRgName string

@description('IP CIDR Block for the Spoke VNET')
param spokeVnetAddressPrefix string

@description('Name of the RG that has the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeVnetName string

@description('IP CIDR Block for the Spring Apps Subnet')
param springAppsSubnetPrefix string

@description('IP CIDR Block for the Spring Apps Runtime Subnet')
param springAppsRuntimeSubnetPrefix string

@description('IP CIDR Block for the Support Subnet')
param supportSubnetPrefix string

@description('Azure Resource Tags')
param tags object

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string

/******************************/
/*     RESOURCES & MODULES    */
/******************************/
resource hubVnetRg 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: hubVnetRgName
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: hubVnetName
  scope: resourceGroup(hubVnetRg.name)
}

resource spokeRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: spokeRgName
  location: location
  tags: tags
}

resource privateZonesRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: privateZonesRgName
  location: location
  tags: tags
}

module spokeVnet '../Modules/vnet.bicep' = {
  name: '${timeStamp}-spoke-vnet'
  scope: resourceGroup(spokeRg.name)
  params: {
    isForSpringApps: true
    name: spokeVnetName
    location: location
    principalId: principalId
    addressPrefixes: [
      spokeVnetAddressPrefix
    ]
    subnets: [
      {
        name: snetRuntimeName
        properties: {
          addressPrefix: springAppsRuntimeSubnetPrefix
          networkSecurityGroup: {
            id: runtimeNsg.outputs.id
          }
        }
      }
      {
        name: snetAppName
        properties: {
          addressPrefix: springAppsSubnetPrefix
          networkSecurityGroup: {
            id: appNsg.outputs.id
          }
        }
      }
      {
        name: snetSupportName
        properties: {
          addressPrefix: supportSubnetPrefix
          networkSecurityGroup: {
            id: supportNsg.outputs.id
          }
        }
      }
      {
        name: snetSharedName
        properties: {
          addressPrefix: sharedSubnetPrefix
          networkSecurityGroup: {
            id: sharedNsg.outputs.id
          }
        }
      }
      {
        name: snetAppGwName
        properties: {
          addressPrefix: appGwSubnetPrefix
          networkSecurityGroup: {
            id: agwNsg.outputs.id
          }
        }
      }
    ]
    tags: tags
  }
  dependsOn: [
    appNsg
    runtimeNsg
    supportNsg
    sharedNsg
    agwNsg
  ]
}

module appNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-app'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetAppNsg
    location: location
    securityRules: []
    tags: tags
  }
}

module runtimeNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-runtime'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetRuntimeNsg
    location: location
    securityRules: []
    tags: tags
  }
}

module supportNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-support'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetSupportNsg
    location: location
    securityRules: []
    tags: tags
  }
}

module sharedNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-shared'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetSharedNsg
    location: location
    securityRules: []
    tags: tags
  }
}

module agwNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-agw'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetAppGwNsg
    location: location
    securityRules: [
      {
        name: 'AllowHTTPSInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHTTPInbound'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          priority: 300
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowAzureLBInbound'
        properties: {
          priority: 400
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
    ]
    tags: tags
  }
}

// Private DNS zone for Spring Apps
module privateZoneSpringApps '../Modules/privateDnsZone.bicep' = {
  name: '${timeStamp}-dns-private-springapps'
  scope: resourceGroup(privateZonesRg.name)
  params: {
    tags: tags
    zoneName: 'private.azuremicroservices.io'
  }
}

module hubVnetSpringAppsZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-dns-hub-link-springapps'
  scope: resourceGroup(privateZonesRg.name)
  dependsOn: [
    privateZoneSpringApps
  ]
  params: {
    vnetName: hubVnet.name
    vnetId: hubVnet.id
    zoneName: 'private.azuremicroservices.io'
    autoRegistration: false
  }
}

module spokeVnetSpringAppsZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-dns-spoke-link-springapps'
  scope: resourceGroup(privateZonesRg.name)
  dependsOn: [
    privateZoneSpringApps
    spokeVnet
  ]
  params: {
    vnetName: spokeVnet.outputs.name
    vnetId: spokeVnet.outputs.id
    zoneName: 'private.azuremicroservices.io'
    autoRegistration: false
  }
}

// Private DNS zone for Key Vault
module privateZoneKv '../Modules/privateDnsZone.bicep' = {
  name: '${timeStamp}-dns-private-kv'
  scope: resourceGroup(privateZonesRg.name)
  params: {
    tags: tags
    zoneName: 'privatelink.vaultcore.azure.net'
  }
}

module hubVnetKvZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-dns-hub-link-kv'
  scope: resourceGroup(privateZonesRg.name)
  dependsOn: [
    privateZoneKv
  ]
  params: {
    vnetName: hubVnet.name
    vnetId: hubVnet.id
    zoneName: 'privatelink.vaultcore.azure.net'
    autoRegistration: false
  }
}

module spokeVnetKvZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-dns-spoke-link-kv'
  scope: resourceGroup(privateZonesRg.name)
  dependsOn: [
    privateZoneSpringApps
    spokeVnet
  ]
  params: {
    vnetName: spokeVnet.outputs.name
    vnetId: spokeVnet.outputs.id
    zoneName: 'privatelink.vaultcore.azure.net'
    autoRegistration: false
  }
}

module hubToSpokePeering '../Modules/virtualNetworkPeering.bicep' = {
  name: '${timeStamp}-vnet-hubToSpokePeering'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    localVnetName: hubVnet.name
    remoteVnetName: spokeVnet.outputs.name
    remoteVnetId: spokeVnet.outputs.id
  }
  dependsOn: [
    spokeVnet
  ]
}

module spokeToHubPeering '../Modules/virtualNetworkPeering.bicep' = {
  name: '${timeStamp}-vnet-spokeToHubPeering'
  scope: resourceGroup(spokeRg.name)
  params: {
    localVnetName: spokeVnet.outputs.name
    remoteVnetName: hubVnet.name
    remoteVnetId: hubVnet.id
  }
  dependsOn: [
    spokeVnet
  ]
}
