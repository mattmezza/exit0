#/bin/env bash

source "./exit0.sh"

setup_test_env() {
    mkdir -p /tmp/test_ls /tmp/test_ls2
    touch /tmp/test_ls/file1.txt
}

teardown_test_env() {
    rm -rf /tmp/test_ls /tmp/test_ls2
}

scenario "ls runs successfully in a clean environment"
when_running "/bin/ls /tmp/test_ls"
then_the_exit_code_should_be 0
and_stdout_should_contain "file1.txt"

scenario "ls should not list non-existent files"
when_running "/bin/ls /tmp/test_ls2"
then_the_exit_code_should_be 0
and_the_stdout_should_be ""

run_teardown
report_results
