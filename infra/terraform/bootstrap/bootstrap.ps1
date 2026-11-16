param(
    [ValidateSet("dev", "stag", "prod")]
    [string]$Environment,
    [ValidateSet("plan", "apply", "destroy")]
    [string]$Action = "plan",
    [string]$StateBucket = "jacobsidhu",
    [string]$StateRegion = "eu-west-2"
)

$ErrorActionPreference = "Stop"

if (-not $Environment) {
    $Environment = (Read-Host "Environment (dev, stag, prod)").Trim().ToLowerInvariant()
}

if ($environment -notin @("dev", "stag", "prod")) {
    throw "Environment must be dev, stag, or prod."
}

Push-Location $PSScriptRoot

try {
    $variablesFile = "$environment.tfvars"
    if (-not (Test-Path -LiteralPath $variablesFile -PathType Leaf)) {
        throw "Terraform variables file '$variablesFile' was not found."
    }

    $stateKey = "terraform/portfolio/$environment/bootstrap/terraform.tfstate"

    @"
bucket       = "$StateBucket"
key          = "$stateKey"
region       = "$StateRegion"
use_lockfile = true
encrypt      = true
"@ | Set-Content -LiteralPath "backend.hcl" -Encoding ascii

    Write-Host "Selected environment $environment"
    Write-Host "State location s3://$StateBucket/$stateKey"

    terraform init -reconfigure "-backend-config=backend.hcl"
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform initialisation failed."
    }

    terraform $Action "-var-file=$variablesFile" "-var=environment=$environment"
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform $Action failed."
    }
}
finally {
    Pop-Location
}
