FROM swift:5.5.2-centos8

# Set up
WORKDIR /mockingbird
COPY . .
RUN yum install -y zip
RUN swift --version

# Build automation
RUN Sources/MockingbirdAutomationCli/buildAndRun.sh
RUN cp .build/debug/automation /usr/bin

# Build generator
RUN Sources/MockingbirdCli/buildAndRun.sh
RUN cp .build/debug/mockingbird /usr/bin

ENTRYPOINT ["mockingbird"]
CMD ["--help"]
