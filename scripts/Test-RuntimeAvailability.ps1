# 配布先が要求する .NET の3種類の取得先を、公開前に確認する。
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$RuntimeVersion
)

$ErrorActionPreference = 'Stop'
$client = [System.Net.Http.HttpClient]::new()
$client.Timeout = [TimeSpan]::FromSeconds(30)

try {
    foreach ($component in @('Hashes', 'DotNet', 'WindowsDesktop')) {
        $url = "https://kamori.goats.dev/Dalamud/Release/Runtime/$component/$RuntimeVersion"
        $response = $client.GetAsync(
            $url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()

        try {
            if (-not $response.IsSuccessStatusCode) {
                throw "ランタイム $RuntimeVersion の $component を取得できません（HTTP $([int]$response.StatusCode)）。config.yaml の runtimeVersion を確認してください。"
            }

            if ($component -eq 'Hashes') {
                $body = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
                $hashes = $body | ConvertFrom-Json
                if ($null -eq $hashes -or @($hashes.PSObject.Properties).Count -eq 0) {
                    throw "ランタイム $RuntimeVersion のハッシュ一覧が空です。"
                }
            }

            # ZIP 本体はここでは読まず、成功応答まで確認して接続を閉じる。
            Write-Host "取得先の確認成功: $component / $RuntimeVersion"
        }
        finally {
            $response.Dispose()
        }
    }
}
finally {
    $client.Dispose()
}
