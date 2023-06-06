# Start by building the application.
FROM ghcr.io/graalvm/graalvm-ce:22.3.1 as build
ENV HOME=/usr/app
RUN mkdir -p $HOME
WORKDIR $HOME

COPY pom.xml pom.xml
COPY src src
RUN <<EOF

  set -euo pipefail
  echo "#################################################"
  echo "Installing latest Apache Maven..."
  echo "#################################################"
  mkdir /opt/maven
  #maven_version=$(curl -fsSL https://repo1.maven.org/maven2/org/apache/maven/apache-maven/maven-metadata.xml | grep -oP '(?<=latest>).*(?=</latest)')
  maven_version=$(curl -fsSL https://repo1.maven.org/maven2/org/apache/maven/apache-maven/maven-metadata.xml | grep -Ev "alpha|beta" | grep -oP '(?<=version>).*(?=</version)' | tail -n1)
  maven_download_url="https://repo1.maven.org/maven2/org/apache/maven/apache-maven/$maven_version/apache-maven-${maven_version}-bin.tar.gz"
  echo "Downloading [$maven_download_url]..."
  curl -fL $maven_download_url | tar zxv -C /opt/maven --strip-components=1
EOF
ENV \
  PATH="/opt/graalvm/bin:/opt/maven/bin:${PATH}" \
  MAVEN_HOME=/opt/maven \
  M2_HOME=/opt/maven \
  MAVEN_CONFIG="/root/.m2" \
  MAVEN_OPTS="-Xmx1024m -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8"
RUN --mount=type=cache,target=/root/.m2 mvn verify -Pnative


FROM scratch as final
ENV PORT 8080
WORKDIR /app
COPY --from=build /usr/app/target/native.bin /app/native.bin
EXPOSE 8080/udp

ENTRYPOINT ["/app/native.bin"]