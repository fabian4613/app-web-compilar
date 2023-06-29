# Dockerfile
FROM ubuntu:20.04

# Define variables de entorno necesarias
ENV DEBIAN_FRONTEND=noninteractive

# Actualiza e instala software-properties-common (necesario para agregar repositorios)
RUN apt-get update && apt-get install -y software-properties-common

# Añade el repositorio 'openjdk-r'
RUN add-apt-repository -y ppa:openjdk-r/ppa

# Actualiza nuevamente e instala OpenJDK 8
RUN apt-get update && apt-get install -y openjdk-8-jdk

# Crear usuario glassfish con permisos de superusuario
RUN useradd -m -s /bin/bash glassfish && echo "glassfish:glassfish" | chpasswd && adduser glassfish sudo

# Establecer la zona horaria a Buenos Aires
ENV TZ=America/Argentina/Buenos_Aires
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Configurar variables de entorno de Java
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Descargar e instalar GlassFish
RUN apt-get install -y wget unzip && \
    wget https://download.oracle.com/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip \
    && unzip glassfish-3.1.2.2.zip -d /opt/ \
    && rm glassfish-3.1.2.2.zip \
    && apt-get remove -y wget unzip \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Establecer variables de entorno
ENV GLASSFISH_HOME=/opt/glassfish3
ENV PATH=$PATH:$GLASSFISH_HOME/bin

# Cambiar la propiedad de la carpeta glassfish al usuario glassfish
RUN chown -R glassfish:glassfish $GLASSFISH_HOME

# Exponer puerto
EXPOSE 8080 4848

# Cambiar al usuario glassfish
USER glassfish

# Copiar archivo WAR a autodeploy
COPY deployments/*.war $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/

# Iniciar GlassFish al arrancar el contenedor
CMD ["asadmin", "start-domain", "-v"]
