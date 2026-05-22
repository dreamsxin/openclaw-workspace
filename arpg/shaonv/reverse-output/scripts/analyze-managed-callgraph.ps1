param(
    [Parameter(Mandatory=$true)]
    [string]$AssemblyPath,

    [Parameter(Mandatory=$true)]
    [string]$CecilPath,

    [Parameter(Mandatory=$true)]
    [string[]]$Types,

    [Parameter(Mandatory=$true)]
    [string]$OutputDir
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Unblock-File -LiteralPath $CecilPath
Add-Type -Path $CecilPath
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$asm = [Mono.Cecil.AssemblyDefinition]::ReadAssembly($AssemblyPath)
$typeSet = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($type in $Types) {
    foreach ($name in ($type -split ",")) {
        $trimmed = $name.Trim()
        if ($trimmed.Length -gt 0) {
            [void]$typeSet.Add($trimmed)
        }
    }
}

$typeRows = New-Object System.Collections.Generic.List[object]
$fieldRows = New-Object System.Collections.Generic.List[object]
$methodRows = New-Object System.Collections.Generic.List[object]
$callRows = New-Object System.Collections.Generic.List[object]
$stringRows = New-Object System.Collections.Generic.List[object]
$fieldRefRows = New-Object System.Collections.Generic.List[object]

function Visit-Type {
    param($type)
    if (-not $typeSet.Contains($type.FullName)) {
        foreach ($nested in $type.NestedTypes) { Visit-Type $nested }
        return
    }

    $baseType = ""
    if ($null -ne $type.BaseType) { $baseType = $type.BaseType.FullName }
    $typeRows.Add([PSCustomObject]@{
        FullName = $type.FullName
        BaseType = $baseType
        MethodCount = $type.Methods.Count
        FieldCount = $type.Fields.Count
    })

    foreach ($field in $type.Fields) {
        $fieldRows.Add([PSCustomObject]@{
            Type = $type.FullName
            Name = $field.Name
            FieldType = $field.FieldType.FullName
            IsStatic = $field.IsStatic
        })
    }

    foreach ($method in $type.Methods) {
        $params = ($method.Parameters | ForEach-Object { "$($_.ParameterType.FullName) $($_.Name)" }) -join "|"
        $methodRows.Add([PSCustomObject]@{
            Type = $type.FullName
            Name = $method.Name
            FullName = $method.FullName
            ReturnType = $method.ReturnType.FullName
            Parameters = $params
            HasBody = $method.HasBody
        })
        if (-not $method.HasBody) { continue }
        foreach ($ins in $method.Body.Instructions) {
            $op = $ins.OpCode.Code.ToString()
            $operand = $ins.Operand
            if ($operand -is [Mono.Cecil.MethodReference]) {
                $callRows.Add([PSCustomObject]@{
                    CallerType = $type.FullName
                    Caller = $method.Name
                    OpCode = $op
                    CalleeType = $operand.DeclaringType.FullName
                    Callee = $operand.Name
                    CalleeFullName = $operand.FullName
                    Offset = $ins.Offset
                })
            } elseif ($operand -is [Mono.Cecil.FieldReference]) {
                $fieldRefRows.Add([PSCustomObject]@{
                    CallerType = $type.FullName
                    Caller = $method.Name
                    OpCode = $op
                    FieldType = $operand.DeclaringType.FullName
                    FieldName = $operand.Name
                    FieldFullName = $operand.FullName
                    Offset = $ins.Offset
                })
            } elseif ($operand -is [string]) {
                $stringRows.Add([PSCustomObject]@{
                    CallerType = $type.FullName
                    Caller = $method.Name
                    Value = $operand
                    Offset = $ins.Offset
                })
            }
        }
    }
}

foreach ($module in $asm.Modules) {
    foreach ($type in $module.Types) {
        Visit-Type $type
    }
}

$typeRows | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "target-types.csv")
$fieldRows | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "target-fields.csv")
$methodRows | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "target-methods.csv")
$callRows | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "target-calls.csv")
$stringRows | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "target-strings.csv")
$fieldRefRows | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "target-fieldrefs.csv")

Write-Output "types=$($typeRows.Count)"
Write-Output "fields=$($fieldRows.Count)"
Write-Output "methods=$($methodRows.Count)"
Write-Output "calls=$($callRows.Count)"
Write-Output "strings=$($stringRows.Count)"
Write-Output "fieldRefs=$($fieldRefRows.Count)"
