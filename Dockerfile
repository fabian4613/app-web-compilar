# Dockerfile
FROM openjdk:7

# Descargar e instalar GlassFish
RUN wget https://download.oracle.com/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip
RUN unzip glassfish-3.1.2.2.zip -d /opt/
RUN rm glassfish-3.1.2.2.zip

# Establecer variables de entorno
ENV GLASSFISH_HOME=/opt/glassfish3
ENV PATH=$PATH:$GLASSFISH_HOME/bin

# Exponer puerto
EXPOSE 8080

# Copiar archivo WAR a autodeploy
COPY target/*.war $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/
