using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Mono.Cecil;
using Mono.Cecil.Cil;

internal static class Program
{
    private static int Main(string[] args)
    {
        if (args.Length < 2)
        {
            PrintUsage();
            return 1;
        }

        var asmPath = Path.GetFullPath(args[0]);
        var resolver = new DefaultAssemblyResolver();
        resolver.AddSearchDirectory(Path.GetDirectoryName(asmPath)!);
        var readerParams = new ReaderParameters { AssemblyResolver = resolver, ReadSymbols = false };
        var asm = AssemblyDefinition.ReadAssembly(asmPath, readerParams);

        if (args[1] == "--find-callers")
        {
            if (args.Length < 3)
            {
                PrintUsage();
                return 1;
            }
            FindCallers(asm, args[2]);
            return 0;
        }

        foreach (var target in args.Skip(1))
        {
            DumpTarget(asm, target);
        }

        return 0;
    }

    private static void PrintUsage()
    {
        Console.Error.WriteLine("usage:");
        Console.Error.WriteLine("  ilprobe <assembly-path> <Type::Method> [<Type::Method>...]");
        Console.Error.WriteLine("  ilprobe <assembly-path> --find-callers <method-name-or-fragment>");
    }

    private static void DumpTarget(AssemblyDefinition asm, string target)
    {
        var parts = target.Split(new[] { "::" }, StringSplitOptions.None);
        if (parts.Length != 2)
        {
            Console.WriteLine("## " + target + "\ninvalid target\n");
            return;
        }

        var typeName = parts[0];
        var methodName = parts[1];
        var type = FindType(asm, typeName);

        if (type == null)
        {
            Console.WriteLine("## " + target + "\ntype not found\n");
            return;
        }

        var methods = type.Methods.Where(m => m.Name == methodName).ToList();
        if (methods.Count == 0)
        {
            Console.WriteLine("## " + target + "\nmethod not found\n");
            return;
        }

        foreach (var method in methods)
        {
            Console.WriteLine("## " + type.FullName + "::" + method.Name);
            Console.WriteLine("Signature: " + method.FullName);
            if (!method.HasBody)
            {
                Console.WriteLine("No body\n");
                continue;
            }

            foreach (var ins in method.Body.Instructions)
            {
                var operand = FormatOperand(ins.Operand);
                Console.WriteLine(string.Format("  IL_{0:X4}: {1,-12} {2}", ins.Offset, ins.OpCode, operand));
            }

            Console.WriteLine();
        }
    }

    private static void FindCallers(AssemblyDefinition asm, string fragment)
    {
        var hits = new List<string>();
        foreach (var type in EnumerateTypes(asm.MainModule.Types))
        {
            foreach (var method in type.Methods)
            {
                if (!method.HasBody)
                    continue;
                foreach (var ins in method.Body.Instructions)
                {
                    if (ins.Operand is MethodReference mr && mr.FullName.IndexOf(fragment, StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        hits.Add(string.Format("{0}::{1} -> {2}", type.FullName, method.Name, mr.FullName));
                    }
                }
            }
        }

        foreach (var hit in hits.Distinct().OrderBy(x => x))
            Console.WriteLine(hit);

        if (hits.Count == 0)
            Console.WriteLine("no callers found");
    }

    private static IEnumerable<TypeDefinition> EnumerateTypes(IEnumerable<TypeDefinition> roots)
    {
        foreach (var type in roots)
        {
            yield return type;
            foreach (var nested in EnumerateTypes(type.NestedTypes))
                yield return nested;
        }
    }

    private static TypeDefinition? FindType(AssemblyDefinition asm, string typeName)
    {
        return EnumerateTypes(asm.MainModule.Types).FirstOrDefault(t => t.FullName == typeName || t.Name == typeName);
    }

    private static string FormatOperand(object? operand)
    {
        if (operand == null)
            return string.Empty;
        if (operand is MethodReference mr)
            return mr.FullName;
        if (operand is FieldReference fr)
            return fr.FullName;
        if (operand is TypeReference tr)
            return tr.FullName;
        if (operand is ParameterDefinition pd)
            return pd.Name;
        if (operand is VariableDefinition vd)
            return "V_" + vd.Index;
        if (operand is Instruction i)
            return "IL_" + i.Offset.ToString("X4");
        if (operand is Instruction[] arr)
            return string.Join(",", arr.Select(x => "IL_" + x.Offset.ToString("X4")));
        return operand.ToString() ?? string.Empty;
    }
}
