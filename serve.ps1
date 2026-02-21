$root = "c:\Projects\GeminiHackathonProj"
$port = 8080
$mime = @{
    '.html' = 'text/html; charset=utf-8'
    '.js'   = 'text/javascript'
    '.css'  = 'text/css'
    '.json' = 'application/json'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.svg'  = 'image/svg+xml'
}

$http = [System.Net.HttpListener]::new()
$http.Prefixes.Add("http://localhost:$port/")
$http.Start()
Write-Host "Serving $root on http://localhost:$port" -ForegroundColor Green

while ($http.IsListening) {
    $ctx  = $http.GetContext()
    $req  = $ctx.Request
    $resp = $ctx.Response

    $relPath = $req.Url.AbsolutePath.TrimStart('/').Replace('/', '\')
    if ($relPath -eq '') { $relPath = 'player.html' }
    $filePath = Join-Path $root $relPath

    if (Test-Path $filePath -PathType Leaf) {
        $ext   = [System.IO.Path]::GetExtension($filePath).ToLower()
        $ctype = if ($mime[$ext]) { $mime[$ext] } else { 'application/octet-stream' }
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $resp.ContentType   = $ctype
        $resp.ContentLength64 = $bytes.Length
        $resp.StatusCode    = 200
        $resp.OutputStream.Write($bytes, 0, $bytes.Length)
        Write-Host "200 $($req.Url.AbsolutePath)"
    } else {
        $resp.StatusCode = 404
        $body = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $relPath")
        $resp.OutputStream.Write($body, 0, $body.Length)
        Write-Host "404 $($req.Url.AbsolutePath)" -ForegroundColor Yellow
    }
    $resp.Close()
}
