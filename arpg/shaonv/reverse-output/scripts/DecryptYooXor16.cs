using System;
using System.IO;
using System.Text.Json;

if (args.Length < 3)
{
    Console.Error.WriteLine("Usage: DecryptYooXor16 <catalog.json> <sourceDir> <outputDir> [keyHex]");
    return 2;
}

var catalogPath = args[0];
var sourceDir = args[1];
var outputDir = args[2];
var key = args.Length >= 4 ? Convert.ToByte(args[3], 16) : (byte)0x16;

Directory.CreateDirectory(outputDir);

using var catalogStream = File.OpenRead(catalogPath);
using var doc = JsonDocument.Parse(catalogStream);
var wrappers = doc.RootElement.GetProperty("Wrappers");

var decoded = 0;
var skipped = 0;
var buffer = new byte[1024 * 1024];

foreach (var wrapper in wrappers.EnumerateArray())
{
    var fileName = wrapper.GetProperty("FileName").GetString();
    if (string.IsNullOrEmpty(fileName))
    {
        skipped++;
        continue;
    }

    var src = Path.Combine(sourceDir, fileName);
    var dst = Path.Combine(outputDir, fileName);
    if (!File.Exists(src))
    {
        Console.Error.WriteLine($"missing: {src}");
        skipped++;
        continue;
    }

    using var input = File.OpenRead(src);
    using var output = File.Create(dst);
    int read;
    while ((read = input.Read(buffer, 0, buffer.Length)) > 0)
    {
        for (var i = 0; i < read; i++)
        {
            buffer[i] ^= key;
        }
        output.Write(buffer, 0, read);
    }

    decoded++;
    if (decoded % 50 == 0)
    {
        Console.WriteLine($"decoded {decoded} files...");
    }
}

File.Copy(catalogPath, Path.Combine(outputDir, "BuildinCatalog.json"), overwrite: true);
var versionPath = Path.Combine(sourceDir, "Default.version");
if (File.Exists(versionPath))
{
    File.Copy(versionPath, Path.Combine(outputDir, "Default.version"), overwrite: true);
}

Console.WriteLine($"done decoded={decoded} skipped={skipped} output={Path.GetFullPath(outputDir)} key=0x{key:X2}");
