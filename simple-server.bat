@echo off
echo Starting simple HTTP server on localhost:8080
echo.
echo This server will work on your computer
echo To access from phone, we'll use port forwarding
echo.
echo Press Ctrl+C to stop the server
echo.

powershell -Command "$listener = New-Object System.Net.HttpListener; $listener.Prefixes.Add('http://localhost:8080/'); $listener.Start(); Write-Host 'Server started successfully on localhost:8080!'; Write-Host 'Access from computer: http://localhost:8080'; Write-Host 'Access from phone: http://192.168.1.19:8080'; while ($listener.IsListening) { $context = $listener.GetContext(); $request = $context.Request; $response = $context.Response; $localPath = $request.Url.LocalPath; if ($localPath -eq '/') { $localPath = '/index.html'; } $filePath = Join-Path (Get-Location) $localPath.TrimStart('/'); if (Test-Path $filePath) { $content = Get-Content $filePath -Raw -Encoding UTF8; $buffer = [System.Text.Encoding]::UTF8.GetBytes($content); $response.ContentLength64 = $buffer.Length; $response.OutputStream.Write($buffer, 0, $buffer.Length); } else { $response.StatusCode = 404; } $response.Close(); }"

pause
