# SportBar — Instalar como app en Android

Estos archivos convierten "SportBar" en una **PWA (Progressive Web App)**:
se instala como un ícono en la pantalla de la tablet, abre a pantalla
completa (sin barra del navegador) y sigue funcionando aunque se corte
el internet momentáneamente.

## Archivos incluidos
- `sport-bar-app.html` — la aplicación.
- `manifest.json` — define el nombre, ícono y colores de la app instalada.
- `sw.js` — service worker, permite que funcione offline.
- `icon-192.png` / `icon-512.png` — íconos de la app.

**Importante:** los 5 archivos deben quedar juntos, en la misma carpeta,
en tu servidor o hosting.

## Paso 1: Subir los archivos a un hosting

Necesitas que los archivos se sirvan por **http o https** (no abrir el
archivo `.html` directo con doble clic — así no funciona el service
worker ni el manifest). Cualquiera de estas opciones sirve:

- Tu propio servidor/hosting (el que ya estás usando).
- Opciones gratuitas rápidas: Netlify, Vercel, GitHub Pages, Firebase Hosting.

## Paso 2: Instalarla en la tablet Android

1. Abre Chrome en la tablet y entra a la URL donde subiste `sport-bar-app.html`.
2. Chrome mostrará un aviso (o desde el menú ⋮ elige **"Instalar app"** /
   **"Agregar a pantalla de inicio"**).
3. Confirma. Aparecerá el ícono de SportBar en el escritorio, y al abrirlo
   se ve como una app nativa, sin la barra del navegador.

Con esto ya tienes el resultado que normalmente buscas con un `.apk`:
ícono propio, pantalla completa, funciona offline.

## Si necesitas un archivo .apk real (por ejemplo, para subir a una tienda)

Yo no puedo compilar un `.apk` — requiere el SDK de Android y firma del
paquete, herramientas que no están disponibles en este entorno de chat.
Pero con los archivos ya listos aquí, generar el `.apk` es un paso rápido
usando una herramienta externa gratuita, **una vez que los archivos ya
estén subidos a una URL pública**:

1. Ve a **https://www.pwabuilder.com**
2. Pega la URL pública de tu `sport-bar-app.html` (donde la hayas subido).
3. PWABuilder detecta el `manifest.json` y el `sw.js` automáticamente.
4. Elige la opción **Android** y descarga el paquete generado
   (puede darte un `.apk` directo o un proyecto para compilar en
   Android Studio, según la opción que elijas).

No requiere que sepas programación — es un formulario web.

## Nota sobre los datos guardados

Esta versión standalone usa el almacenamiento del propio navegador
(`localStorage`) en vez del almacenamiento de Claude.ai, así que los
datos (mesas, ventas, inventario) quedan guardados en el dispositivo
donde se use — igual si la abres como página web o como app instalada.
