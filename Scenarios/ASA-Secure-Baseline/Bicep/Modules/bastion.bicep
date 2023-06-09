param location string
param name string
param subnetId string
param tags object

resource bastionIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'azure-bastion-ip'
  location: location
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
  tags: tags
}

resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      { name: 'configuration', properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: bastionIP.id
          }
        }
      }
    ]
  }
  tags: tags
}
