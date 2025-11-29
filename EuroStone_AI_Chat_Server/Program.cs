using Microsoft.EntityFrameworkCore;
using Microsoft.SemanticKernel;
using EuroStone_AI_Chat_Server.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();

// Add Database Context
builder.Services.AddDbContext<EuroStone_AI_Chat_Server.Data.AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Semantic Kernel with Ollama (via OpenAI connector)
builder.Services.AddKernel()
    .AddOpenAIChatCompletion(
        modelId: "llama3.2",
        apiKey: "ollama", // Ignored by Ollama
        endpoint: new Uri("http://localhost:11434/v1"),
        httpClient: new HttpClient { Timeout = TimeSpan.FromMinutes(5) }
    );
builder.Services.AddTransient<EuroStone_AI_Chat_Server.Services.OllamaService>();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
