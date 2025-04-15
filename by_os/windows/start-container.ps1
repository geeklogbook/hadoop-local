param (
    [int]$N = 3
)

# Verificar si la red 'hadoop' existe, si no, crearla
if (-not (docker network ls | Select-String "hadoop")) {
    Write-Output "Creating Docker network 'hadoop'"
    docker network create hadoop
}

# Iniciar el contenedor de hadoop-master
Write-Output "Starting hadoop-master container"
docker rm -f hadoop-master

docker run -itd `
    --net=hadoop `
    -p 50070:50070 `
    -p 8088:8088 `
    --name hadoop-master `
    --hostname hadoop-master `
    uracilo/hadoop

# Inicializar los contenedores esclavos
for ($i = 1; $i -lt $N; $i++) {
    Write-Output "Starting hadoop-slave$i container"
    docker rm -f hadoop-slave$i
    
    docker run -itd `
        --net=hadoop `
        --name hadoop-slave$i `
        --hostname hadoop-slave$i `
        uracilo/hadoop
}

# Verificar si el contenedor master está corriendo
Start-Sleep -Seconds 2
$status = docker inspect -f "{{.State.Running}}" hadoop-master 2>$null

if ($status -eq "true") {
    Write-Output "Entering hadoop-master container..."
    docker exec -it hadoop-master bash
} else {
    Write-Output "hadoop-master is not running. Showing logs..."
    docker logs hadoop-master
}