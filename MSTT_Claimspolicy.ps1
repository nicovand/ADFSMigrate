$JSONPolicy= @"
{
"ClaimsMappingPolicy":{
"Version":1,
"IncludeBasicClaimSet":"false",
"ClaimsSchema":
[
{
"Source": "user",
"ID": "userprincipalname",
"SamlClaimType":"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"
},
{
"Source": "user",
"ID": "groups",
"SamlClaimType":"http://schemas.xmlsoap.org/claims/group"
},
{
"Source": "user",
"ID": "mail",
"SamlClaimType":"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
},
{
"Source":"user",
"ID":"onpremisessamaccountname"
},
{
"Source":"user",
"ID":"netbiosname"
},
{
"Source":"transformation",
"ID":"DataJoin",
"TransformationId":"JoinTheData",
"SAMLClaimType":"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
}
],
"ClaimsTransformations":
[
{
"ID":"JoinTheData",
"TransformationMethod":"Join",
"InputClaims":
[
{
"ClaimTypeReferenceId":"onpremisessamaccountname",
"TransformationClaimType":"string2"
},
{
"ClaimTypeReferenceId":"netbiosname",
"TransformationClaimType":"string1"
}
], 
"InputParameters":[
{
"ID":"separator",
"Value":"\\"
}
],
"OutputClaims":
[
{
"ClaimTypeReferenceId":"DataJoin",
"TransformationClaimType":"outputClaim"
}
]
}
]
}
}
"@

$cm = $JSONPolicy -replace '\s',''
$param = @{definition = $cm; displayname = "mytest"; Type="ClaimsMappingPolicy"}
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
