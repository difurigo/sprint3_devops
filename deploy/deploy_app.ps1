# Publica e faz zip deploy
$APP_NAME="<<copie o valor exibido no create_resources.ps1>>"
$RG="rg-devops-mottu"

dotnet restore
dotnet publish -c Release -o ./publish

Compress-Archive -Path ./publish/* -DestinationPath ./publish.zip -Force

az webapp deploy -g $RG -n $APP_NAME --src-path ./publish.zip

Write-Host "Abra: https://$APP_NAME.azurewebsites.net/swagger"