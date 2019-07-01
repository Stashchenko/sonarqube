#!/usr/bin/env bash

colored_print () {
  if [[ "$2" == "red" ]]; then
    printf "\e[31m$1\e[m\n"
  elif [[ "$2" == "yellow" ]]; then
    printf "\e[33m$1\e[m\n"
  else
    printf "\e[32m$1\e[m\n"
  fi
}


colored_print "Initializing variables & folders"
GOMETALINTER_FILE=tmp/report.out
TEST_FILE=tmp/coverage.out
PROJECT=`basename "$PWD"`
mkdir -p tmp

rm -f GOMETALINTER_FILE
rm -f TEST_FILE

generate_property(){
cat > sonar-project.properties << EOF
sonar.projectKey=$PROJECT
sonar.projectVersion=1.0
sonar.go.golint.reportPaths=$GOMETALINTER_FILE
sonar.go.coverage.reportPaths=$TEST_FILE
sonar.sources=.
sonar.exclusions=**/*.bazel, tmp/**, main.go
sonar.test.inclusions=**/*_test.go
EOF
}


colored_print "Check required apps..."
if brew ls --versions sonarqube > /dev/null; then
  colored_print "SonarQube has already installed" yellow
else
    colored_print "Installing SonarQube..."
    brew install sonarqube
    brew install sonar-scanner
    brew services start sonarqube
fi

if which golangci-lint >/dev/null; then
   colored_print "golangci-lint has already installed" yellow
else
   colored_print "Installing golangci-lint..."
   go get -u github.com/golangci/golangci-lint/cmd/golangci-lint
fi

colored_print "Installing latest goconvey..." yellow
go get github.com/smartystreets/goconvey > /dev/null 2>&1

colored_print "Generating sonar-project.properties..."
generate_property

colored_print "Running go test..."
CONFIG_DIR=${PWD%/*/*}/config/local go test ./... -covermode=count -coverprofile=$TEST_FILE

if [[ $? -eq 0 ]]; then
    colored_print "Test OK\nRunning golangci-lint..."
    golangci-lint run --out-format=line-number --tests=false > $GOMETALINTER_FILE

    colored_print "Running sonar-scanner..."
    sonar-scanner
else
    colored_print "Test FAIL, SonarScanner analysis stopped" red
fi
