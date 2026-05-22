param(
    [Parameter(Mandatory=$true)]
    [string]$AssemblyPath,

    [Parameter(Mandatory=$true)]
    [string]$CecilPath,

    [string[]]$Patterns = @("*")
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -Path $CecilPath

$readerParams = New-Object Mono.Cecil.ReaderParameters
$readerParams.ReadSymbols = $false
$asm = [Mono.Cecil.AssemblyDefinition]::ReadAssembly($AssemblyPath, $readerParams)

function Test-MatchAny {
    param([string]$Text, [string[]]$Patterns)
    foreach ($pattern in $Patterns) {
        if ($Text -like $pattern) {
            return $true
        }
    }
    return $false
}

function Get-AllTypes {
    param([Mono.Cecil.TypeDefinition]$Type)
    $Type
    foreach ($nested in $Type.NestedTypes) {
        Get-AllTypes $nested
    }
}

foreach ($module in $asm.Modules) {
    foreach ($topType in $module.Types) {
    foreach ($type in (Get-AllTypes $topType)) {
        $typeName = $type.FullName
        $typeHit = Test-MatchAny $typeName $Patterns
        $methodHit = $false
        foreach ($method in $type.Methods) {
            if (Test-MatchAny "$typeName::$($method.Name)" $Patterns) {
                $methodHit = $true
                break
            }
        }
        if (-not ($typeHit -or $methodHit)) {
            continue
        }

        Write-Output "TYPE $typeName"
        foreach ($field in $type.Fields) {
            Write-Output "  FIELD $($field.FieldType.FullName) $($field.Name)"
        }
        foreach ($method in $type.Methods) {
            if (-not ($typeHit -or (Test-MatchAny "$typeName::$($method.Name)" $Patterns))) {
                continue
            }
            $params = ($method.Parameters | ForEach-Object { "$($_.ParameterType.FullName) $($_.Name)" }) -join ", "
            Write-Output "  METHOD $($method.ReturnType.FullName) $($method.Name)($params)"
            if ($method.HasBody) {
                foreach ($var in $method.Body.Variables) {
                    Write-Output "    VAR $($var.Index) $($var.VariableType.FullName)"
                }
                foreach ($ins in $method.Body.Instructions) {
                    $operand = ""
                    if ($null -ne $ins.Operand) {
                        $operand = $ins.Operand.ToString()
                    }
                    Write-Output ("    IL_{0:x4}: {1,-12} {2}" -f $ins.Offset, $ins.OpCode.Code, $operand)
                }
            }
        }
    }
    }
}
