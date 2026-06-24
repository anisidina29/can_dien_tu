# Script cap nhat thong tin cong ty - Can Dien Tu FarmPlus
# Dat file nay CUNG THU MUC voi Chuongtrinhcan.exe roi chay

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Tu dong tim thu muc chua Chuongtrinhcan.exe
# Ho tro 2 cau truc: dat cung cap voi exe, hoac co subfolder App\
if (Test-Path (Join-Path $scriptDir "Chuongtrinhcan.exe")) {
    $appDir = $scriptDir
} elseif (Test-Path (Join-Path $scriptDir "App\Chuongtrinhcan.exe")) {
    $appDir = Join-Path $scriptDir "App"
} else {
    Write-Host "LOI: Khong tim thay Chuongtrinhcan.exe" -ForegroundColor Red
    Write-Host "Hay dat file nay cung thu muc voi Chuongtrinhcan.exe" -ForegroundColor Yellow
    Read-Host "Nhan Enter de thoat"
    exit 1
}

$exePath = Join-Path $appDir "Chuongtrinhcan.exe"
$mdbPath = Join-Path $appDir "sys\data.mdb"

Write-Host ""
Write-Host "=== CAP NHAT THONG TIN FARMPLUS ===" -ForegroundColor Cyan
Write-Host "Thu muc phan mem: $appDir" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Path $mdbPath)) {
    Write-Host "LOI: Khong tim thay $mdbPath" -ForegroundColor Red
    Read-Host "Nhan Enter de thoat"
    exit 1
}

# Tat app neu dang chay
Write-Host "[1/3] Tat phan mem neu dang chay..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.Name -like "*Chuongtrinhcan*" } | ForEach-Object {
    $_.Kill()
    Write-Host "      Da tat process: $($_.Name)" -ForegroundColor Green
}
Start-Sleep -Milliseconds 500

# Patch EXE: xoa chu "ANH CHI" tai offset 160326
Write-Host "[2/3] Patch EXE (xoa dong ANH CHI)..." -ForegroundColor Yellow
try {
    $bytes = [System.IO.File]::ReadAllBytes($exePath)
    $offset = 160326
    $tag = [System.Text.Encoding]::UTF8.GetString($bytes, $offset, 7)
    if ($tag -eq "ANH CHI") {
        for ($i = 0; $i -lt 7; $i++) { $bytes[$offset + $i] = 0x20 }
        [System.IO.File]::WriteAllBytes($exePath, $bytes)
        Write-Host "      Da xoa 'ANH CHI' thanh cong." -ForegroundColor Green
    } elseif ($tag.Trim() -eq "") {
        Write-Host "      EXE da duoc patch truoc do (offset trong)." -ForegroundColor Green
    } else {
        Write-Host "      CANH BAO: Offset 160326 = '$tag' - co the EXE khac phien ban." -ForegroundColor Yellow
    }
} catch {
    Write-Host "      LOI patch EXE: $_" -ForegroundColor Red
}

# Cap nhat database
Write-Host "[3/3] Cap nhat database (ten cty + MST)..." -ForegroundColor Yellow
try {
    $conn = New-Object System.Data.OleDb.OleDbConnection
    $pass = '!@#^%$Nguyen1Van2A3'
    $conn.ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=$mdbPath;Jet OLEDB:Database Password=$pass;"
    $conn.Open()

    $tenCty = "C" + [char]0x00D4 + "NG TY TNHH FARMPLUS"
    $mst    = "1501164307"

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "UPDATE giaotiep SET diachi=?, tencty=?, dienthoai=?"
    $null = $cmd.Parameters.Add("?", [System.Data.OleDb.OleDbType]::VarWChar); $cmd.Parameters[0].Value = $tenCty
    $null = $cmd.Parameters.Add("?", [System.Data.OleDb.OleDbType]::VarWChar); $cmd.Parameters[1].Value = $tenCty
    $null = $cmd.Parameters.Add("?", [System.Data.OleDb.OleDbType]::VarWChar); $cmd.Parameters[2].Value = $mst

    $rows = $cmd.ExecuteNonQuery()
    $conn.Close()
    Write-Host "      Cap nhat thanh cong: ten='$tenCty', mst='$mst' ($rows dong)" -ForegroundColor Green
} catch {
    Write-Host "      LOI database: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== HOAN THANH ===" -ForegroundColor Cyan
Write-Host "Mo phan mem Can Dien Tu de kiem tra." -ForegroundColor White
Write-Host ""
Read-Host "Nhan Enter de thoat"
