@description('Specifies the name of the key vault.')
param keyVaultName string

@description('Specifies the secrets that you want to create.')
param secrets array = []

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [
  for (secret, index) in secrets: {
    name: secret.Name
    parent: kv
    properties: {
      value: secret.Value
    }
  }
]

output name string = kv.name
output resourceGroupName string = resourceGroup().name
output resourceId string = kv.id
