# ===== CONFIG =====
$RG="rg-devops-mottu"
$LOCATION="brazilsouth"
$APP_PLAN="asp-mottu-dev"
$APP_NAME="api-mottu-$(Get-Random)"           # precisa ser único globalmente
$MYSQL_NAME="mysql-mottu-$(Get-Random)"       # precisa ser único globalmente
$MYSQL_ADMIN="admroot"
$MYSQL_PASS="S3nh@Forte!123"                  # demo; em produção use Key Vault
$DB_NAME="motosdb"
$RUNTIME="DOTNET|9.0"

# ===== RESOURCE GROUP =====
az group create -n $RG -l $LOCATION

# ===== MYSQL FLEXIBLE SERVER =====
# Dica: --public-access 0.0.0.0 permite acesso público (facilita o App Service e seu IP para demo)
az mysql flexible-server create `
  -g $RG -n $MYSQL_NAME -l $LOCATION `
  --admin-user $MYSQL_ADMIN --admin-password $MYSQL_PASS `
  --version 8.0 --sku-name B_Standard_B1ms --storage-size 20 `
  --public-access 0.0.0.0

# Criar o banco dentro do servidor
az mysql flexible-server db create -g $RG -s $MYSQL_NAME -d $DB_NAME

# Pegar FQDN
$MYSQL_FQDN = az mysql flexible-server show -g $RG -n $MYSQL_NAME --query "fullyQualifiedDomainName" -o tsv

# ===== APP SERVICE PLAN + WEB APP =====
az appservice plan create -g $RG -n $APP_PLAN --is-linux --sku B1
az webapp create -g $RG -p $APP_PLAN -n $APP_NAME --runtime $RUNTIME

# ===== CONNECTION STRING (MySQL) =====
# Importante: SslMode=Required (Azure exige TLS na maioria dos casos)
$CONN = "Server=$MYSQL_FQDN;Port=3306;Database=$DB_NAME;Uid=$MYSQL_ADMIN;Pwd=$MYSQL_PASS;SslMode=Required;TreatTinyAsBoolean=false;"
az webapp config connection-string set -g $RG -n $APP_NAME `
  --settings DefaultConnection="$CONN" --connection-string-type MySql

# ===== APP SETTINGS =====
az webapp config appsettings set -g $RG -n $APP_NAME --settings ASPNETCORE_ENVIRONMENT=Production

# Output final
Write-Host "APP_URL: https://$APP_NAME.azurewebsites.net"
Write-Host "MYSQL_FQDN: $MYSQL_FQDN"