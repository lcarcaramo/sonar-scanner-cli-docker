# Tags
> _Built from [`quay.io/ibmz/openjdk:11.0.8`](https://quay.io/repository/ibmz/openjdk?tab=info)_
-	[`4.5.0.2216`](https://github.com/lcarcaramo/sonar-scanner-cli-docker/blob/master/s390x/4/Dockerfile) - [![Build Status](https://travis-ci.com/lcarcaramo/sonar-scanner-cli-docker.svg?branch=master)](https://travis-ci.com/lcarcaramo/sonar-scanner-cli-docker)

# What is SonarScanner CLI

SonarScanner CLI is the command line tool used with [SonarQube](https://quay.io/repository/ibmz/sonarqube) to perform static code analysis on source code.

:warning: This Docker image is not compatible with C/C#/C++/Objective-C projects.

# How to use this image

* Start a `[quay.io/ibmz/sonarqube:8.5.1.38104](https://quay.io/repository/ibmz/sonarqube)` container.
> _Wait about 40 seconds for sonarqube to be ready before performing static code analysis._

* Create a Docker volume place your source code, and a `sonar-project.properties` file in the root directory of that volume.
  ```console
  $ docker volume create <name of your project>
  ```

  ```properties
  # sonar-project.properties
  sonar.projectKey=<arbitrary.project.key>
  sonar.projectName=<name of your project>
  sonar.sources=/usr/src
  sonar.language=<Language the source code is written in>
  sonar.sourceEncoding=<encoding (ie., UTF-8)>
   ```

* Once SonarQube is ready, run SonarScanner CLI to perform static code analysis on your code.
  ```console
  $ curl -u admin:admin http://<host/ip where sonarqube is running>:<port if necessary>/api/system/health
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                   Dload  Upload   Total   Spent    Left  Speed
  100    30  100    30    0     0     41      0 --:--:-- --:--:-- --:--:--    41{"health":"GREEN","causes":[]}
  ```
  ```console
  $ docker run --rm \
               -e SONAR_HOST_URL="http://<host/ip where sonarqube is running>:<port if necessary>/api/system/health" \
               -v <name of your project>:/usr/src \
               quay.io/ibmz/sonar-scanner-cli:4.5.0.2216 \
  ```

See the [SonarScanner CLI](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/) documentation for more details.

# License

Copyright 2015-2020 SonarSource.

Licensed under the [GNU Lesser General Public License, Version 3.0](http://www.gnu.org/licenses/lgpl.txt)
