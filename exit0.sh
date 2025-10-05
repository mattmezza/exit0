#!/bin/env bash

LAST_CMD_STDOUT=""
LAST_CMD_STDERR=""
LAST_CMD_EXIT_CODE=""
TEST_SUCCESS=0
TEST_FAILURES=0
TEST_SCENARIOS=0

# ANSI escape codes for formatting
i="\033[3m" # italic
b="\033[1m" # bold
n="\033[0m" # normal
green="\033[32m" # green
red="\033[31m" # red

L1="  "
L2="    "
L3="      "

assert() {
    local result="$1"
    local message="$2"
    if [[ "$result" -eq 0 ]]; then
        echo -e "${L3}${b}${green}✅PASS$n: ${i}${message}${n}"
        TEST_SUCCESS=$((TEST_SUCCESS + 1))
    else
        echo -e "${L3}${b}${red}❌FAIL$n: ${i}${message}${n}"
        TEST_FAILURES=$((TEST_FAILURES + 1))
    fi
}

when_running() {
    local cmd="$1" # Use $1 since the caller provides only the command string

    # We must reset the state of LAST_CMD_... before the execution
    LAST_CMD_STDOUT=""
    LAST_CMD_STDERR=""
    LAST_CMD_EXIT_CODE=""

    # Use a subshell to execute the command and capture its ${i}output$n and ${i}exit code$n reliably
    # We use a temporary script file to handle the execution and exit status capture cleanly.
    local tmp_script=$(mktemp)
    local tmp_stdout=$(mktemp)
    local tmp_stderr=$(mktemp)

    # 1. Write a small script that executes the command and saves the exit code
    # The `exec` ensures the redirection persists for the command run by eval.
    cat << EOF > "$tmp_script"
#!/bin/env bash
exec 1>"$tmp_stdout" 2>"$tmp_stderr"
${cmd}
exit \$?
EOF

    # 2. Execute the temporary script and capture the ${i}exit code$n of the execution
    # We run it in a subshell to prevent it from affecting the main shell state.
    bash "$tmp_script"
    LAST_CMD_EXIT_CODE=$?

    # 3. Read the captured output/error
    LAST_CMD_STDOUT=$(cat "$tmp_stdout")
    LAST_CMD_STDERR=$(cat "$tmp_stderr")

    # 4. Clean up
    rm "$tmp_script" "$tmp_stdout" "$tmp_stderr"

    echo -e "${L1}When running '${b}${cmd}$n'"
}

then_the_exit_code_should_be() {
    local expected="$1"
    echo -e "${L2}${i}exit code$n should be '${i}${expected}${n}'"
    assert \
        $([[ $LAST_CMD_EXIT_CODE -eq $expected ]] && echo 0 || echo 1) \
        "exit code '${i}${LAST_CMD_EXIT_CODE}$n' matches expected '${i}${expected}${n}'"
}
and_the_exit_code_should_be() { then_the_exit_code_should_be "$1"; }
and_exit_code_should_be() { then_the_exit_code_should_be "$1"; }
the_exit_code_should_be() { then_the_exit_code_should_be "$1"; }
exit_code_should_be() { then_the_exit_code_should_be "$1"; }

then_the_stdout_should_contain() {
    local expected="$1"
    echo -e "${L2}${i}stdout$n should contain '${i}${expected}${n}'"
    local result=$(echo "$LAST_CMD_STDOUT" | grep -F "$expected")
    assert \
        $([[ -n "$result" ]] && echo 0 || echo 1) \
        "${i}stdout$n contains '${i}${expected}${n}'"
}
and_the_stdout_should_contain() { then_the_stdout_should_contain "$1"; }
and_stdout_should_contain() { then_the_stdout_should_contain "$1"; }
the_stdout_should_contain() { then_the_stdout_should_contain "$1"; }
stdout_should_contain() { then_the_stdout_should_contain "$1"; }

then_the_stdout_should_NOT_contain() {
    local unexpected="$1"
    echo -e "${L2}${i}stdout$n should ${b}NOT$n contain '${i}${unexpected}${n}'"
    # Use grep -v (invert match) and check if the result is empty (no lines matched the pattern)
    local result=$(echo "$LAST_CMD_STDOUT" | grep -F "$unexpected")
    assert \
        $([[ -z "$result" ]] && echo 0 || echo 1) \
        "${i}stdout$n does ${b}NOT$n contain '${i}${unexpected}${n}'"
}
and_the_stdout_should_NOT_contain() { then_the_stdout_should_NOT_contain "$1"; }
and_stdout_should_NOT_contain() { then_the_stdout_should_NOT_contain "$1"; }
the_stdout_should_NOT_contain() { then_the_stdout_should_NOT_contain "$1"; }
stdout_should_NOT_contain() { then_the_stdout_should_NOT_contain "$1"; }

then_the_stdout_should_be() {
    local expected="$1"
    echo -e "${L2}${i}stdout$n should be '${i}${expected}$n'"
    # Note: Bash string comparison includes newlines, making this exact
    assert \
        $([[ "$LAST_CMD_STDOUT" == "$expected" ]] && echo 0 || echo 1) \
        "${i}stdout$n exactly matches '${i}${expected}${n}'"
}
and_the_stdout_should_be() { then_the_stdout_should_be "$1"; }
and_stdout_should_be() { then_the_stdout_should_be "$1"; }
the_stdout_should_be() { then_the_stdout_should_be "$1"; }
stdout_should_be() { then_the_stdout_should_be "$1"; }

then_the_stdout_should_NOT_be() {
    local unexpected="$1"
    echo -e "${L2}${i}stdout$n should %{b}NOT$n be '${i}${unexpected}${n}'"
    assert \
        $([[ "$LAST_CMD_STDOUT" != "$unexpected" ]] && echo 0 || echo 1) \
        "${i}stdout$n does ${b}NOT$n match '${i}${unexpected}${n}'"
}
and_the_stdout_should_NOT_be() { then_the_stdout_should_NOT_be "$1"; }
and_stdout_should_NOT_be() { then_the_stdout_should_NOT_be "$1"; }
the_stdout_should_NOT_be() { then_the_stdout_should_NOT_be "$1"; }
stdout_should_NOT_be() { then_the_stdout_should_NOT_be "$1"; }

then_the_exit_code_should_NOT_be() {
    local unexpected="$1"
    echo -e "${L2}${i}exit code$n should ${b}NOT$n be '${i}${unexpected}${n}'"
    assert \
        $([[ $LAST_CMD_EXIT_CODE -ne $unexpected ]] && echo 0 || echo 1) \
        "exit code '${i}${LAST_CMD_EXIT_CODE}$n' ${b}DOES NOT$n match '${i}${unexpected}$n'"
}
and_the_exit_code_should_NOT_be() { then_the_exit_code_should_NOT_be "$1"; }
and_exit_code_should_NOT_be() { then_the_exit_code_should_NOT_be "$1"; }
the_exit_code_should_NOT_be() { then_the_exit_code_should_NOT_be "$1"; }
exit_code_should_NOT_be() { then_the_exit_code_should_NOT_be "$1"; }

then_the_exit_code_should_be_higher_than() {
    local value="$1"
    echo "${L2}${i}exit code$n should be higher than '${i}${value}${n}'"
    # Use arithmetic comparison `(( ... ))`
    assert \
        $((( LAST_CMD_EXIT_CODE > value )) && echo 0 || echo 1) \
        "exit code '${i}${LAST_CMD_EXIT_CODE}$n' is greater than '${i}${value}${n}'"
}
and_the_exit_code_should_be_higher_than() { then_the_exit_code_should_be_higher_than "$1"; }
and_exit_code_should_be_higher_than() { then_the_exit_code_should_be_higher_than "$1"; }
the_exit_code_should_be_higher_than() { then_the_exit_code_should_be_higher_than "$1"; }
exit_code_should_be_higher_than() { then_the_exit_code_should_be_higher_than "$1"; }

then_the_exit_code_should_be_lower_than() {
    local value="$1"
    echo "${L2}${i}exit code$n should be lower than '${i}${value}${n}'"
    assert \
        $((( LAST_CMD_EXIT_CODE < value )) && echo 0 || echo 1) \
        "exit code ${i}${LAST_CMD_EXIT_CODE}$n is less than '${i}${value}${n}'"
}
and_the_exit_code_should_be_lower_than() { then_the_exit_code_should_be_lower_than "$1"; }
and_exit_code_should_be_lower_than() { then_the_exit_code_should_be_lower_than "$1"; }
the_exit_code_should_be_lower_than() { then_the_exit_code_should_be_lower_than "$1"; }
exit_code_should_be_lower_than() { then_the_exit_code_should_be_lower_than "$1"; }

then_the_stderr_should_contain() {
    local expected="$1"
    echo "${L2}${i}stderr$n should contain '${i}${expected}${n}'"
    local result=$(echo "$LAST_CMD_STDERR" | grep -F "$expected")
    assert \
        $([[ -n "$result" ]] && echo 0 || echo 1) \
        "${i}stderr$n contains '${i}${expected}$n'"
}
and_the_stderr_should_contain() { then_the_stderr_should_contain "$1"; }
and_stderr_should_contain() { then_the_stderr_should_contain "$1"; }
the_stderr_should_contain() { then_the_stderr_should_contain "$1"; }
stderr_should_contain() { then_the_stderr_should_contain "$1"; }

then_the_stderr_should_be_empty() {
    echo "${L2}${i}stderr$n should be empty"
    # Checks if the LAST_CMD_STDERR variable is zero length
    assert \
        $([[ -z "$LAST_CMD_STDERR" ]] && echo 0 || echo 1) \
        "${i}stderr$n is empty"
}
and_the_stderr_should_be_empty() { then_the_stderr_should_be_empty; }
and_stderr_should_be_empty() { then_the_stderr_should_be_empty; }
the_stderr_should_be_empty() { then_the_stderr_should_be_empty; }
stderr_should_be_empty() { then_the_stderr_should_be_empty; }

begin_scenario() {
    local name="$1"
    local description="$2" # Optional description
    TEST_SCENARIOS=$((TEST_SCENARIOS + 1))
    echo -e "${b}# Scenario $TEST_SCENARIOS: ${i}\"${name}\"$n"
    echo -e "${L1}${i}${description}$n"

    # Check for user-defined setup functions and run them
    if declare -f setup_scenario_$name > /dev/null; then
        setup_scenario_$name
        echo -e "${L1}${i}(scenario set up successfully)$n"
    fi
}

end_scenario() {
    # Check for user-defined teardown functions and run them
    if declare -f teardown_scenario_$scenario > /dev/null; then
        teardown_scenario_$scenario
        echo -e "${L1}${i}(scenario teared down successfully)$n"
    fi
}

begin_test() {
    local descr="$1"
    echo -e "${i}${descr}$n"
    # Check for user-defined setup functions and run them
    if declare -f setup_test > /dev/null; then
        setup_test
        echo -e "${i}(test set up successfully)$n"
    fi
}

report_results() {
    local tests=$TEST_SCENARIOS
    local tot=$(($TEST_SUCCESS + $TEST_FAILURES))
    local passed=$TEST_SUCCESS
    local failed=$TEST_FAILURES
    if [[ $failed -eq 0 ]]; then
        echo -e "\n${green}${b}✅TESTS PASSED! ${n}"
        echo -e "${L1}${i}${passed} passed assertions (in $tests tests)$n"
        return 0
    else
        echo -e "\n${red}${b}❌TESTS FAILED! ${n}"
        echo -e "${L1}${i}${failed} failure over $tot assertions (in $tests tests)$n"
        return 1
    fi
}

end_test() {
    # Check for user-defined teardown functions and run them
    if declare -f teardown_test > /dev/null; then
        teardown_test
        echo -e "${i}(test teared down successfully)$n"
    fi
    report_results
}
