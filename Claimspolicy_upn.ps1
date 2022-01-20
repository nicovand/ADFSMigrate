$JSONPolicy= @"
{
"ClaimsMappingPolicy": {
"Version": 1,
"IncludeBasicClaimSet": "false",
"ClaimsSchema": [
{
"Source": "user",
"ID": "userprincipalname",
"SamlClaimType":"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"
}
]
}
}
"@


$cm = $JSONPolicy -replace '\s',''
$param = @{definition = $cm; displayname = "UPN"; Type="ClaimsMappingPolicy"}
$newPolicy = New-AzureADPolicy @param
$targetPolicyId = $newPolicy.Id


$appname = "Claimstest"

# Find Service Principal object of Enterprise Application in question and put in double quotes below.
$appID = (Get-AzureADApplication -filter "displayname eq '$appname'").appid
$EnterpriseAppobjectID = (Get-AzureADServicePrincipal -Filter "servicePrincipalNames/any(n: n eq '$appID')").ObjectID


# Remove Old Policy from Service Principal
$oldPolicy = Get-AzureADServicePrincipalPolicy -id $EnterpriseAppobjectID
if (-not($null -eq $oldPolicy))
{
    $oldPolicyId = $oldPolicy.Id
    Remove-AzureADServicePrincipalPolicy -Id $EnterpriseAppobjectID -PolicyId $oldPolicyId
}


# Assign new Policy to Service Principal
Add-AzureADServicePrincipalPolicy -Id $EnterpriseAppobjectID -RefObjectId $targetPolicyId





if ($RemovePolicy)
{
    Remove-AzureADServicePrincipalPolicy -Id $EnterpriseAppobjectID -PolicyId $targetPolicyId
}