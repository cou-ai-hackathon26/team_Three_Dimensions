param(
    [ValidateSet("qwen", "llama")]
    [string]$Model = "qwen",
    [string]$FilePath = ""
)

# Automated upload of On-Device Models (Qwen 2.5 0.5B / LLaMA 3.2 1B) to Cloudflare R2
$envFile = "$PSScriptRoot\.env.r2"
if (-not (Test-Path $envFile)) {
    Write-Error "scripts\.env.r2 file not found."
    exit 1
}

Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#")) {
        $parts = $line.Split("=", 2)
        if ($parts.Length -eq 2) {
            $key = $parts[0].Trim()
            $val = $parts[1].Trim()
            if ($key -and $val) {
                [System.Environment]::SetEnvironmentVariable($key, $val, "Process")
            }
        }
    }
}

if (-not $env:CLOUDFLARE_ACCOUNT_ID -or -not $env:CLOUDFLARE_API_TOKEN) {
    Write-Warning "CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_API_TOKEN are not set in scripts\.env.r2."
    Write-Warning "To upload directly via wrangler CLI, please populate credentials in scripts\.env.r2"
    Write-Warning "Alternatively, you can drag and drop the GGUF file directly into your Cloudflare Dashboard -> R2 -> mylaws-models bucket."
}

if ($Model -eq "qwen") {
    $targetKey = "Qwen2.5-0.5B-Instruct-Q4_K_M.gguf"
    $defaultPath = "D:\Download\Qwen2.5-0.5B-Instruct-Q4_K_M.gguf"
    $modelName = "Qwen 2.5 0.5B Instruct (~398 MB)"
} else {
    $targetKey = "Llama-3.2-1B-Instruct-Q4_K_M.gguf"
    $defaultPath = "D:\Download\Llama-3.2-1B-Instruct-Q4_K_M.gguf"
    $modelName = "LLaMA 3.2 1B Instruct (~808 MB)"
}

$modelFile = if ($FilePath) { $FilePath } else { $defaultPath }

Write-Output "=========================================================="
Write-Output "  MyLaws Model Upload Utility: $modelName"
Write-Output "  Target Cloudflare R2 Bucket: mylaws-models"
Write-Output "  R2 Object Key: $targetKey"
Write-Output "  Source File: $modelFile"
Write-Output "=========================================================="

if (-not (Test-Path $modelFile)) {
    Write-Warning "Local model file not found at: $modelFile"
    Write-Output "Download $modelName (GGUF format) from HuggingFace to your downloads folder,"
    Write-Output "then re-run: .\scripts\upload_model_to_r2.ps1 -Model $Model -FilePath <path_to_gguf>"
    exit 0
}

npx wrangler r2 object put "mylaws-models/$targetKey" --file="$modelFile" --remote
