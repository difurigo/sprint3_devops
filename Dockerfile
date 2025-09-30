# ===== build =====
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copia o csproj e restaura dependências
COPY MottuApi/*.csproj ./MottuApi/
RUN dotnet restore ./MottuApi/MottuApi.csproj

# Copia o restante do código
COPY . .

# Publica
RUN dotnet publish ./MottuApi/MottuApi.csproj -c Release -o /app/publish /p:UseAppHost=false

# ===== runtime =====
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Cria usuário não-root
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser:appuser /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

USER appuser
ENTRYPOINT ["dotnet", "MottuApi.dll"]