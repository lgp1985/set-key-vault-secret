# Login to Azure
Connect-AzAccount -WarningAction Ignore

# Set the vault name
$subscriptionLeft = "subscription1"
$vaultNameLeft = "kv-1"
$subscriptionRight = "subscription2"
$vaultNameRight = "kv-2"

function Get-KeyVaultSecrets {
    param(
        [Parameter(Mandatory = $true)]
        [string]$subscription,

        [Parameter(Mandatory = $true)]
        [string]$vaultName
    )
    <#
    .SYNOPSIS
       Retrieves all secrets and their values from a specified Azure Key Vault.
    
    .DESCRIPTION
       The Get-KeyVaultSecrets function connects to Azure, switches to the specified subscription, and retrieves all secrets and their values from the specified Azure Key Vault.
    
    .PARAMETER subscription
       The subscription ID where the Azure Key Vault is located.
    
    .PARAMETER vaultName
       The name of the Azure Key Vault.
    
    .EXAMPLE
       Get-KeyVaultSecrets -subscription "your-subscription" -vaultName "your-vault-name"
    #>

    # Change to respective subscription
    Set-AzContext -Subscription $subscription

    # Get all secrets from the vault
    $secrets = Get-AzKeyVaultSecret -VaultName $vaultName

    # Loop through each secret
    foreach ($secret in $secrets) {
        # Get the stored value of the secret
        $secretValue = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secret.Name -AsPlainText 

        # Add the secret value as a new property to the secret object
        $secret | Add-Member -MemberType NoteProperty -Name SecretValue -Value $secretValue
    }

    # Return the secrets with their values
    return $secrets
}

# Get the secrets from the left vault
$secretsLeft = Get-KeyVaultSecrets -subscription $subscriptionLeft -vaultName $vaultNameLeft

# Get the secrets from the right vault
$secretsRight = Get-KeyVaultSecrets -subscription $subscriptionRight -vaultName $vaultNameRight

# Get the secrets that are in the left vault but not in the right vault
$secretsOnlyInLeft = $secretsLeft | Where-Object { $_.Name -notin $secretsRight.Name }

# Get the secrets that are in the right vault but not in the left vault
$secretsOnlyInRight = $secretsRight | Where-Object { $_.Name -notin $secretsLeft.Name }

# Get the secrets that are in both vaults but have different values
$secretsDifferentValues = $secretsLeft | Where-Object { $secretLeft = $_; $secretsRight | Where-Object { $_.Name -eq $secretLeft.Name -and $_.SecretValue -ne $secretLeft.SecretValue } }

# Get the secrets that are in both vaults and have the same values
$secretsSameValues = $secretsLeft | Where-Object { $secretLeft = $_; $secretsRight | Where-Object { $_.Name -eq $secretLeft.Name -and $_.SecretValue -eq $secretLeft.SecretValue } }

# Get the counts of the secrets in each category
$secretsCounts = @{
    SecretsOnlyInLeft = $secretsOnlyInLeft.Count
    SecretsOnlyInRight = $secretsOnlyInRight.Count
    SecretsDifferentValues = $secretsDifferentValues.Count
    SecretsSameValues = $secretsSameValues.Count
}

# Get the secrets names in each category
$secretsNames = @{
    SecretsOnlyInLeft = $secretsOnlyInLeft.Name
    SecretsOnlyInRight = $secretsOnlyInRight.Name
    SecretsDifferentValues = $secretsDifferentValues.Name
    SecretsSameValues = $secretsSameValues.Name
}

# Output the counts of the secrets in each category
Write-Host "Number of secrets in each category:" -ForegroundColor Green
$secretsCounts

# Output the names of the secrets in each category
Write-Host "Names of secrets in each category:" -ForegroundColor Green
$secretsNames