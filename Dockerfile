FROM openjdk:10 as builder
MAINTAINER Prometheus Team <prometheus-developers@googlegroups.com>
EXPOSE 9106

WORKDIR /cloudwatch_exporter
ADD . /cloudwatch_exporter
RUN apt-get -qy update && apt-get -qy install maven && mvn package && \
    mv target/cloudwatch_exporter-*-with-dependencies.jar /cloudwatch_exporter.jar && \
    rm -rf /cloudwatch_exporter && apt-get -qy remove --purge maven && apt-get -qy autoremove

FROM openjdk:10-jre-slim as runner
WORKDIR /
RUN mkdir /config
ONBUILD ADD config.yml /config/
COPY --from=builder /cloudwatch_exporter.jar /cloudwatch_exporter.jar
ENTRYPOINT [ "java", "-jar", "/cloudwatch_exporter.jar", "9106"]
CMD ["/config/config.yml"]
