function New-AzCosmosDbDatabase {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$AccountName,
    
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string]$DatabaseName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Locations,

        [parameter()]
        [switch]$EnableMultipleWriteLocations
    )


    # Microsoft.DocumentDB/databaseAccounts/apis/databases/write
    # https://docs.microsoft.com/en-us/azure/cosmos-db/scripts/powershell/sql/ps-sql-create?toc=%2fpowershell%2fmodule%2ftoc.json

    $location = Get-AzResourceGroup -Name $ResourceGroupName | Select-Object -ExpandProperty 'Location'

    $consistencyPolicy = @{
        "defaultConsistencyLevel" = "BoundedStaleness";
        "maxIntervalInSeconds"    = 300;
        "maxStalenessPrefix"      = 100000
    }

    $CosmosDBProperties = @{
        "databaseAccountOfferType" = "Standard";
        "consistencyPolicy"        = $consistencyPolicy;
    }
    if ([string]::IsNullOrWhiteSpace($Locations)) {
        $priority = 0
        $Locations | ForEach-Object {
            $CosmosDBProperties.locations += @{
                'locationName'     = $_;
                'failoverPriority' = $priority
            }
            $priority += 1
        }
    }
    if ($EnableMultipleWriteLocations) {
        $CosmosDBProperties.enalbeMultipleWriteLocations = 'true'
    }

    New-AzResource -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
        -ApiVersion "2015-04-08" -ResourceGroupName $ResourceGroupName -Location $location `
        -Name $AccountName -PropertyObject $CosmosDBProperties

}