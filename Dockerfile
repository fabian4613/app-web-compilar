# Dockerfile
FROM ubuntu:20.04

# Actualiza el sistema e instala Java 7
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-7-jre-headless=7u51-2.4.6-1ubuntu4 \
    openjdk-7-jre=7u51-2.4.6-1ubuntu4 \
    openjdk-7-jdk=7u51-2.4.6-1ubuntu4

# Crear usuario glassfish con permisos de superusuario
RUN useradd -m -s /bin/bash glassfish && echo "glassfish:glassfish" | chpasswd && adduser glassfish sudo

# Establecer la zona horaria a Buenos Aires
ENV TZ=America/Argentina/Buenos_Aires
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Descarga tu archivo tar.gz de Java en el contenedor
RUN wget -P /opt https://packages.baidu.com/app/jdk-8/jdk-8u144-linux-x64.tar.gz && \
    tar zxvf /opt/jdk-8u144-linux-x64.tar.gz -C /opt && \
    rm /opt/jdk-8u144-linux-x64.tar.gz

# Configurar variables de entorno de Java
ENV JAVA_HOME=/opt/jdk1.8.0_144
ENV PATH=$PATH:$JAVA_HOME/bin

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
