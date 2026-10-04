# PowerShell Windows — Scripting Rules

## Core Principles

### 1. Command Separation
- **Wrong:** `cd "path" && command` (bash syntax)
- **Correct:** `cd "path"; command` (PowerShell syntax)

### 2. Path Quoting
- Always use double quotes for paths with spaces.

### 3. Script Execution
- For .bat/.cmd files: `.\gradlew.bat clean build`

### 4. Docker Commands
- Full path to compose files: `docker-compose -f "path\to\file.yml" up -d`

### 5. HTTP Requests
- **Wrong:** `curl -s http://localhost:9090/status`
- **Correct:** `Invoke-WebRequest -Uri "http://localhost:9090/status" -UseBasicParsing`

### 6. Waiting
- **Wrong:** `timeout 10`
- **Correct:** `Start-Sleep -Seconds 10`

### 7. JSON Handling
```powershell
$response = Invoke-WebRequest -Uri "http://localhost:9090/status" -UseBasicParsing
$json = $response.Content | ConvertFrom-Json
```

### 8. Error Handling
```powershell
Get-Process -Name "java" -ErrorAction SilentlyContinue
```

## Common Errors and Fixes

| Error | Cause | Fix |
|---|---|---|
| `&& is not recognized` | Bash syntax | Replace with `;` |
| `curl not found` | curl not on Windows | Use `Invoke-WebRequest` |
| `timeout not found` | Not supported | Use `Start-Sleep` |

## Correct Examples

```powershell
# Change dir and execute
cd "D:\My Projects\MyApp"; ./gradlew clean build -x test

# Wait and HTTP request
Start-Sleep -Seconds 10; Invoke-WebRequest -Uri "http://localhost:9090/status" -UseBasicParsing

# Docker
docker-compose -f "D:\My Projects\MyApp\docker-compose.yml" down
docker-compose -f "D:\My Projects\MyApp\docker-compose.yml" build --no-cache
docker-compose -f "D:\My Projects\MyApp\docker-compose.yml" up -d
```
