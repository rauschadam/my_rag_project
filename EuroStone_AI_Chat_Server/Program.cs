using Microsoft.EntityFrameworkCore;
using Microsoft.SemanticKernel;
using EuroStone_AI_Chat_Server.Data;

// Létrehozza a webalkalmazás építőt (builder), ami segít beállítani a szolgáltatásokat és a konfigurációt.
var builder = WebApplication.CreateBuilder(args);

// --- Szolgáltatások (Services) hozzáadása a konténerhez ---
// A Dependency Injection (DI) konténer kezeli az objektumok élettartamát és függőségeit.

// Hozzáadja a Controller-eket (API végpontok kezelői).
builder.Services.AddControllers();

// Adatbázis kontextus (AppDbContext) hozzáadása.
// Ez teszi lehetővé az adatbázissal való kommunikációt az Entity Framework Core segítségével.
// A kapcsolat stringet (ConnectionString) a konfigurációból (appsettings.json) olvassa ki.
builder.Services.AddDbContext<EuroStone_AI_Chat_Server.Data.AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Semantic Kernel hozzáadása az AI funkciókhoz.
// Itt konfiguráljuk az Ollama-t (helyi AI modell futtató), de az OpenAI csatlakozón keresztül használjuk.
builder.Services.AddKernel()
    .AddOpenAIChatCompletion(
        modelId: "llama3.2", // A használt modell neve
        apiKey: "ollama", // Az Ollama nem igényel valódi API kulcsot, de a mező nem lehet üres.
        endpoint: new Uri("http://localhost:11434/v1"), // Az Ollama helyi elérési útja.
        httpClient: new HttpClient { Timeout = TimeSpan.FromMinutes(5) } // Időtúllépés beállítása (5 perc), mert az AI válasza lassú lehet.
    );

// Regisztráljuk a saját OllamaService szolgáltatásunkat, ami az AI logikát tartalmazza.
// A "Transient" azt jelenti, hogy minden kérésnél új példány jön létre belőle.
builder.Services.AddTransient<EuroStone_AI_Chat_Server.Services.OllamaService>();

// OpenAPI (Swagger) dokumentáció konfigurálása.
// Ez segít az API felfedezésében és tesztelésében.
builder.Services.AddOpenApi();

// --- Az alkalmazás felépítése ---
var app = builder.Build();

// --- A HTTP kérés-válasz csővezeték (Pipeline) konfigurálása ---

// Ha fejlesztői környezetben vagyunk, engedélyezzük az OpenAPI (Swagger) felületet.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

// HTTPS átirányítás (biztonságos kapcsolatra kényszerítés).
app.UseHttpsRedirection();

// Engedélyezés (Authorization) middleware. (Jelenleg nincs bonyolult auth logika, de a keretrendszer része).
app.UseAuthorization();

// A Controller-ek végpontjainak (route-ok) feltérképezése.
app.MapControllers();

// Az alkalmazás futtatása.
app.Run();
