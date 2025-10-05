#/bin/env bash

source "./exit0.sh"

setup_test() {
    mkdir -p /tmp/ls_test_env
}

teardown_test() {
    rm -rf /tmp/ls_test_env
}

begin_test \
    "This test suite checks the functionality of the 'ls' command."

# Setup function to create test files and directories
# Note: the function name must match the scenario name
# pattern: setup_scenario_<scenario_name>()
setup_scenario_ls_list() {
    mkdir -p /tmp/ls_test_env/ls_list
    touch /tmp/ls_test_env/ls_list/file1.txt
    touch /tmp/ls_test_env/ls_list/file2.txt
}

# Teardown function to clean up after the test
# pattern: teardown_scenario_<scenario_name>()
teardown_scenario_ls_list() {
    rm -rf /tmp/ls_test_env/ls_list
}

# name - must be unique and not contain spaces
begin_scenario "ls_list" \
    "It should list files in a directory." # description - can contain spaces
    when_running "ls /tmp/ls_test_env/ls_list"
    then_the_exit_code_should_be 0
    and_stdout_should_contain "file1.txt"
    and_stdout_should_contain "file2.txt"
end_scenario "ls_list" # must match the scenario name - will call the teardown


setup_scenario_ls_list_nonexistent() {
    mkdir -p /tmp/ls_test_env/ls_list_nonexistent
}

teardown_scenario_ls_list_nonexistent() {
    rm -rf /tmp/ls_test_env/ls_list_nonexistent
}

begin_scenario "ls_list_nonexistent" \
    "It should not list non-existent files."
    when_running "ls /tmp/ls_test_env/ls_list_nonexistent"
    then_the_exit_code_should_be 0
    and_the_stdout_should_be ""
end_scenario "ls_list_nonexistent"

end_test
