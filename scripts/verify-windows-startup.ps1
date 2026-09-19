$ErrorActionPreference = 'Stop'
# Install only on the disposable runner when the native runtime is absent.
$runtime = Get-ChildItem "${env:ProgramFiles(x86)}/Microsoft/EdgeWebView/Application/*/msedgewebview2.exe" -ErrorAction SilentlyContinue
if (-not $runtime) {
    Invoke-WebRequest 'https://go.microsoft.com/fwlink/p/?LinkId=2124703' -OutFile "$env:TEMP/WebView2Setup.exe"
    $installer = Start-Process "$env:TEMP/WebView2Setup.exe" -ArgumentList '/silent','/install' -Wait -PassThru
    Write-Host "WebView2 installer exit: $($installer.ExitCode)"
}
Get-ChildItem "${env:ProgramFiles(x86)}/Microsoft/EdgeWebView/Application/*/msedgewebview2.exe" -ErrorAction Stop
npm install --prefix target/startup-qa --no-save playwright@1.58.2
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$env:NODE_PATH = "$pwd/target/startup-qa/node_modules"
node scripts/verify-windows-startup.mjs
exit $LASTEXITCODE
