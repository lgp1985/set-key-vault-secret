# params
$paramFile = "secrets.json"
$ResourceGroupName = "DefaultResourceGroup-EUS2"
$deploymentName = "Set.kv-lgp-test01.secrets"

# Deploy the template
New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $ResourceGroupName -TemplateFile "kv-secrets.bicep" -TemplateParameterFile  $paramFile