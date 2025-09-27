using MottuApi.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// ==========================
// Controllers + JSON
// ==========================
// Ignora ciclos para evitar loop de serialização (relações bidirecionais no EF)
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.WriteIndented = true;
    });

// ==========================
// DbContext (MySQL via Pomelo)
// ==========================
builder.Services.AddDbContext<MottuDbContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        ServerVersion.AutoDetect(builder.Configuration.GetConnectionString("DefaultConnection"))
    ));

// ==========================
// Swagger / OpenAPI
// ==========================
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "API Mottu - Gestão de Funcionários e Pátios",
        Version = "v1",
        Description = "API RESTful para cadastro e login de funcionários da Mottu, com gestão de pátios e gerentes.",
        Contact = new OpenApiContact
        {
            Name = "Equipe de Desenvolvimento",
            Email = "equipe@mottu.com"
        }
    });
});

var app = builder.Build();

// ==========================
// Migrations automáticas
// ==========================
// Aplica migrations pendentes ao iniciar (útil no deploy em nuvem)
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<MottuDbContext>();
    await db.Database.MigrateAsync();
}

// ==========================
// Pipeline HTTP
// ==========================
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "API Mottu v1");
    c.RoutePrefix = string.Empty; // Swagger acessível na raiz
});

// Em dev, sem https configurado no launchSettings, este middleware pode dar aviso.
// Em produção, mantenha para redirecionamento seguro.
app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
