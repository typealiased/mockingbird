FROM swift:5.5.2-centos8

# Set up
WORKDIR /mockingbird
COPY . .
RUN swift --version

# Build
RUN Sources/MockingbirdCli/buildAndRun.sh --configuration release

# Copy artifacts
RUN mkdir -p /usr/bin/Libraries
RUN cp .build/release/mockingbird /usr/bin
RUN cp Sources/MockingbirdCli/Resources/Libraries/lib_InternalSwiftSyntaxParser.dylib /usr/bin/Libraries

ENTRYPOINT ["mockingbird"]
CMD ["--help"]
