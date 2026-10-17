# JSP/Servlets (javax.*) con Apache Tomcat 9 y Java 17
FROM tomcat:9.0-jdk17-temurin

# Render espera un servicio HTTP accesible en el puerto 10000
RUN rm -rf /usr/local/tomcat/webapps/* \
    && sed -i 's/port="8080"/port="10000"/' /usr/local/tomcat/conf/server.xml

# Permitir que Tomcat sustituya ${DB_PASSWORD} en WEB-INF/web.xml
# por la variable definida de forma privada en Render.
ENV CATALINA_OPTS="-Dorg.apache.tomcat.util.digester.PROPERTY_SOURCE=org.apache.tomcat.util.digester.EnvironmentPropertySource"

# Publicar las paginas JSP directamente en la raiz del dominio
COPY . /usr/local/tomcat/webapps/ROOT/

EXPOSE 10000
CMD ["catalina.sh", "run"]
