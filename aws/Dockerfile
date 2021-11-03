# Start from this image on https://hub.docker.com (the public docker repo)
# This gives us a known starting point to configure from for each build
FROM amazoncorretto:11-alpine-jdk

# Let docker know that our app is listening on port 10025 when it runs
EXPOSE 10025

ADD target/*-jar-with-dependencies.jar /usr/share/aws-smtp-relay/aws-smtp-relay.jar

ENTRYPOINT ["/usr/bin/java", "-jar",
            "/usr/share/aws-smtp-relay/aws-smtp-relay.jar", "-b", "0.0.0.0",
                                                            "-al", "EmailServerAuthenticationLambdaFunction",
                                                             "--region", "us-east-1",
                                                              "--sourceArn", "arn:aws:ses:us-east-1:079714096672:identity/development.cloud.powerside.com"]
