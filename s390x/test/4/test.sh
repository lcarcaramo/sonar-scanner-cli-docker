#!/bin/bash

set -e

export ANSI_YELLOW_BOLD="\e[1;33m"
export ANSI_GREEN="\e[32m"
export ANSI_YELLOW_BACKGROUND="\e[1;7;33m"
export ANSI_GREEN_BACKGROUND="\e[1;7;32m"
export ANSI_CYAN_BACKGROUND="\e[1;7;36m"
export ANSI_CYAN="\e[36m"
export ANSI_RESET="\e[0m"
export DOCKERFILE_TOP="**************************************** DOCKERFILE ******************************************"
export DOCKERFILE_BOTTOM="**********************************************************************************************"
export TEST_SUITE_START="**************************************** SMOKE TESTS *****************************************"
export TEST_SUITE_END="************************************** TEST SUCCESSFUL ***************************************"

# Pass in path to folder where Dockerfile lives
print_dockerfile () {
        echo -e "\n$ANSI_CYAN$DOCKERFILE_TOP\n$(<$1/Dockerfile)\n$ANSI_CYAN$DOCKERFILE_BOTTOM $ANSI_RESET\n"
}

# Pass in test case message
print_test_case () {
        echo -e "\n$ANSI_YELLOW_BOLD$1 $ANSI_RESET"
}

print_success () {
        echo -e "\n$ANSI_GREEN$1 $ANSI_RESET \n"

}

wait_until_ready () {
        export SECONDS=$1
        export SLEEP_INTERVAL=$(echo $SECONDS 50 | awk '{ print $1/$2 }')

        echo -e "\n${ANSI_CYAN}Waiting ${SECONDS} seconds until ready: ${ANSI_RESET}"

        for second in {1..50}
        do
                echo -ne "${ANSI_CYAN_BACKGROUND} ${ANSI_RESET}"
                sleep ${SLEEP_INTERVAL}
        done

        echo -e "${ANSI_CYAN} READY${ANSI_RESET}"
}


# Pass in path to folder where Dockerfile lives
build () {
        print_dockerfile $1
        docker build -t $1 $1
}

cleanup () {
        docker rmi $1
}

suite_start () {
        echo -e "\n$ANSI_YELLOW_BACKGROUND$TEST_SUITE_START$ANSI_RESET \n"
}

suite_end () {
        echo -e "\n$ANSI_GREEN_BACKGROUND$TEST_SUITE_END$ANSI_RESET \n"
}


suite_start
        print_test_case "It can scan source code:"
                docker run --name sonarqube -d -p 9000:9000 quay.io/ibmz/sonarqube:8.5.1.38104
                echo -e "\n${ANSI_CYAN}Starting SonarQube from the quay.io/ibmz/soniarqube:8.5.1.38104 image...${ANSI_RESET}"
                wait_until_ready 40

                build "scans-source-code"
                echo -e "\n${ANSI_CYAN}Starting static code analysis using the quay.io/ibmz/sonar-scanner-cli:4.5.0.2216 image...${ANSI_RESET}\n"
                docker run --name sonar-scanner-cli --network container:sonarqube -e SONAR_HOST_URL="http://localhost:9000" "scans-source-code"
                print_success "Success! static code analysis was performed using the quay.io/ibmz/sonar-scanner-cli:4.5.0.2216 image"

                docker rm -f sonar-scanner-cli
                docker rm -f sonarqube
                cleanup "scans-source-code"
suite_end
