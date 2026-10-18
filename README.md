# cft — Cloudflare Tunnel Control

Script Bash para iniciar y detener un túnel de Cloudflare (`cloudflared tunnel run --token`)
de forma sencilla, leyendo el token desde una variable de entorno definida en tu `.bashrc`.

## 📋 Requisitos

- `cloudflared` instalado y disponible en el `PATH`.
- Bash (v4+ recomendado, para la expansión indirecta `${!var}`).
- Linux o macOS.

Verifica que `cloudflared` esté instalado:

```bash
cloudflared --version
```

Si no lo tienes, instálalo desde:
https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/

## 📦 Instalación

1. Guarda el script como `cft` (ver sección **Script** más abajo).

2. Cópialo a `/usr/local/bin` y dale permisos de ejecución:

```bash
sudo cp cft /usr/local/bin/cft
sudo chmod +x /usr/local/bin/cft
```

3. Verifica que esté disponible:

```bash
which cft
# /usr/local/bin/cft
```

> `/usr/local/bin` ya está en el `PATH` por defecto, así que no necesitas modificar tu `.bashrc`
> para que el comando esté disponible. Solo necesitas el `.bashrc` para definir los tokens.

## 🔑 Configurar el token en `.bashrc`

Añade una o varias variables de entorno con tus tokens en `~/.bashrc`:

```bash
# ~/.bashrc
export CLOUDFLARE_TOKEN_MI_TUNEL="eyJhIjoi...tu_token_largo..."
export CLOUDFLARE_TOKEN_OTRO_TUNEL="eyJhIjoi...otro_token..."
```

Recarga el archivo para que estén disponibles en la sesión actual:

```bash
source ~/.bashrc
```

> ⚠️ **Seguridad**: el token es una credencial sensible. Cualquiera que lo tenga puede
> ejecutar el túnel. No lo subas a repositorios públicos ni lo dejes en scripts compartidos.
> Si tu `.bashrc` es legible por otros usuarios del sistema, considera protegerlo
> (`chmod 600 ~/.bashrc`) o usar un gestor de secretos.

## 🚀 Uso

```bash
cft up NOMBRE_VARIABLE   # Inicia el túnel usando el token de esa variable
cft down                 # Detiene el túnel en ejecución
cft status               # Muestra el estado actual
```

### Ejemplos

```bash
# Inicia el túnel cuyo token está en $CLOUDFLARE_TOKEN_MI_TUNEL
cft up CLOUDFLARE_TOKEN_MI_TUNEL

# Ver estado
cft status
# Estado: 🟢 Corriendo (PID: 12345)
# Logs:   /tmp/cft-cloudflared.log

# Detener
cft down
# Deteniendo túnel (PID: 12345)...
# ✅ Túnel detenido.
```

## 🧠 Cómo funciona

- **`cft up NOMBRE_VARIABLE`**:
  - Comprueba que no haya otro túnel activo (según el PID file).
  - Resuelve el valor de la variable de entorno de forma indirecta con `${!var_name}`.
  - Si la variable no existe o está vacía, muestra un error explicativo.
  - Lanza `cloudflared tunnel run --token "$token"` con `nohup` en segundo plano.
  - Guarda el PID en `/tmp/cft-cloudflared.pid` y los logs en `/tmp/cft-cloudflared.log`.

- **`cft down`**:
  - Lee el PID guardado y envía `SIGTERM` al proceso.
  - Espera hasta 10 s a que termine; si no lo hace, envía `SIGKILL`.
  - Elimina el PID file.

- **`cft status`**:
  - Verifica si el proceso del PID file sigue activo.

Ventaja frente a `pkill cloudflared`: solo mata **el proceso que tú iniciaste**,
no cualquier `cloudflared` que esté corriendo en el sistema.

## 📂 Archivos que utiliza

| Archivo                       | Propósito                             |
|-------------------------------|---------------------------------------|
| `/tmp/cft-cloudflared.pid`    | PID del túnel en ejecución            |
| `/tmp/cft-cloudflared.log`    | Logs de `cloudflared` (útil para depurar) |

Para ver los logs en tiempo real:

```bash
tail -f /tmp/cft-cloudflared.log
```

## ⚠️ Notas

- Solo puede haber **un túnel activo a la vez**. Si quieres ejecutar varios en paralelo,
  necesitarías adaptar el script para usar un PID file por variable.
- El token se lee del `.bashrc` del **usuario que ejecuta el comando**. Si lo ejecutas
  con `sudo` u otro usuario, la variable no existirá y el script fallará.
- Si cierras la terminal, el túnel **sigue corriendo** gracias a `nohup`.
  Debes detenerlo explícitamente con `cft down`.
- Al reiniciar el sistema, el túnel **no se reinicia automáticamente** (no es un servicio).
  Para persistencia real, considera `sudo cloudflared service install <TOKEN>`.

## 🧩 Script

Guarda el siguiente contenido en un archivo llamado `cft`:


## 📄 Licencia

Uso libre. Modifícalo a tu gusto.

