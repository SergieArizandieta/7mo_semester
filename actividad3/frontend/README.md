## Arrglando problema de rutas en version de producción en server nginx con react

### Raiz del problema:
Lo que pasa es que al utilizar React y utilizar React Router este tras bambalinas es únicamente un renderizado condicionalmente del URL que está mostrando esto pasa cuando se utiliza la versión de producción debido a que el build que genera react es una librería que hace single page aplication es decir se caracteriza porque todo carga en la primera petición que se hace al servidor.


Es decir desde nuestra ruta “home” o la main que tenga la página ahí recibe toda la aplicación y desde esa parta todas las secciones de manejo de rutas esta cargado, ya solo es de ir navegando, debido a esto se visitamos una ruta que no sea la main y se la primera vez que lo consultemos no nos brindara nada porque no tenemos toda la aplicación y solo estamos visitando una página aparentemente inexistente.


Este problema es cuando usamos la aplicación de producción directamente sin apoyo de un servidor, ya que este error puede ser solventado con estrategias del lado del servidor para poder mostrar las rutas correspondientes a lo que se conoce como server side rendering.


Aunque cabe resaltar que con React también se puede arreglar utilizando HashRouter que se utiliza para verificar si el componente está dentro de un contexto de enrutador, que se utiliza para envolver la aplicación React y proporcionar el contexto de enrutamiento necesario para la funcionalidad de enrutamiento en la aplicación.


Pero en este caso se realizara una configuración en el servidor nginx para solucionar dicho problema.

### Crear archivo nginx.conf
Deberemos agregar la siguiente configuracion:
```
# nginx.conf
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
  worker_connections  1024;
}
http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
  '$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';
  access_log  /var/log/nginx/access.log  main;
  sendfile        on;
  keepalive_timeout  65;
   server {
   listen 80;
   location / {
      root   /usr/share/nginx/html;
      index  index.html index.htm;
      try_files $uri $uri/ /index.html;
   }
   }
}
```

### Especificaciones del archivo de configuracion:
- user: especifica el usuario del sistema operativo que ejecutará los procesos de Nginx.

- worker_processes: define el número de procesos de Nginx que se ejecutarán en paralelo.

- error_log: especifica el archivo de registro de errores de Nginx.

- pid: especifica la ubicación del archivo de identificación del proceso de Nginx.

- events: sección que define la configuración del módulo de eventos de Nginx, que maneja las conexiones de red.

- http: sección principal de configuración de Nginx para el protocolo HTTP.

- include: incluye un archivo de configuración adicional que contiene definiciones de tipos de medios MIME.

- default_type: define el tipo de archivo predeterminado que se enviará si no se especifica un tipo MIME.

- log_format: define el formato de registro de acceso a utilizar para los registros de acceso de Nginx.

- access_log: especifica el archivo de registro de acceso de Nginx.

- sendfile: habilita el uso del sistema de envío de archivos de alta velocidad de Nginx.

- keepalive_timeout: define el tiempo máximo que Nginx mantendrá una conexión TCP abierta.

- server: define una configuración de servidor para Nginx.

- listen: especifica la dirección IP y el puerto en el que el servidor debe escuchar las solicitudes entrantes.

- location: define la ubicación de los archivos en el servidor.

- root: define la ubicación de la raíz del directorio de documentos del servidor.

- index: especifica los archivos que se utilizarán como página de inicio del servidor.

- try_files: define una serie de archivos para buscar en caso de que no se encuentre el archivo solicitado.

En resumen, el archivo nginx.conf define la configuración principal de Nginx, incluyendo los archivos de registro, la ubicación de los archivos en el servidor, la raíz del directorio de documentos y la configuración del servidor web en sí.

### Ahora este archivo debera ser argreago al nginx.Dockerfile
Linea que lo realiza:
```
COPY nginx.conf /etc/nginx/nginx.conf
```

Que dandonos nuestro nginx.Dockerfile de la siguiente manera:
```
## BUILD
# docker build -t mifrontend:0.1.0-nginx-alpine -f nginx.Dockerfile .
## RUN
# docker run -d -p 3000:80 mifrontend:0.1.0-nginx-alpine
FROM node:18.14.0-buster-slim as compilacion

LABEL developer="Sergie Arizandieta" \
      email="sergiearizandieta@gmail.com"

ENV REACT_APP_BACKEND_BASE_URL=http://localhost:3800

# Copy app
COPY . /opt/app

WORKDIR /opt/app

# Npm install
RUN npm install

RUN npm run build

# Fase 2
FROM nginx:1.22.1-alpine as runner
COPY --from=compilacion /opt/app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
```


