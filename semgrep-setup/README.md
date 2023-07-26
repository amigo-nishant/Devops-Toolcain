This is to install and configure the semgrep OSS tool to perform the Static Application Security Testing(SAST) on our javascript projects.
Pre-requisites for semgrep:

Install Python3
Install pip

Installing semgrep:
pip3 install semgrep
Command to run the semgrep locally on the server
semgrep --config auto
Command to run rhe semgrep locally and store the report in file
semgrep --config auto --output report.json --json
Semgrep docuementation reference link: https://semgrep.dev/docs/getting-started/