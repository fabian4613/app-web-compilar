# Dockerfile
FROM ubuntu:18.04

# Actualizar el sistema e instalar las utilidades necesarias
RUN apt-get update && apt-get install -y wget unzip openjdk-8-jdk sudo

# Crear usuario glassfish con permisos de superusuario
RUN useradd -m -s /bin/bash glassfish && echo "glassfish:glassfish" | chpasswd && adduser glassfish sudo

# Establecer la zona horaria a Buenos Aires
ENV TZ=America/Argentina/Buenos_Aires
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Descargar e instalar GlassFish
RUN wget https://download.oracle.com/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip \
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
