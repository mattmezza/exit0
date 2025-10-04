![exit0 banner](docs/banner.png)

exit0
===

🚀 BDD testing for your CLI apps, in pure bash!

`exit0` it's a lightweight, pure Bash lib designed for [Behavior-Driven
Development (BDD)](https://en.wikipedia.org/wiki/Behavior-driven_development),
making your tests super readable!

## 🤔 What does it do?

It helps you test your CLI app in a clean, isolated environment (a subshell)
and checks three crucial things:

1. What it prints to your screen (`stdout`) ✍️
1. Any error messages it throws (`stderr`) 🚨
1. If it finished successfully or crashed (exit codes) ✅❌

The name `exit0` is a little wink 😉 to the `0` exit code that signals success
in the Bash world!

Also, it is a play on the Spanish word *"éxito"* which means *"success"*.

<details>
  <summary>DEMO</summary>
    <img src="docs/banner.gif" alt="exit0 demo">
</details>

## ✨ Why You'll Love `exit0`

Here's a quick peek at why `exit0` is awesome:
- minimal dependencies (just `grep` and `cat`)
- **It's pure Bash**: single file (`exit0.sh`). No installs, no complex setup.
- **Human-Readable Tests**: tests that make sense, even to non-devs.
- **Comprehensive Assertions**: check everything from exact output, partial strings, empty errors, to precise or comparative exit codes.
- **Instant Feedback!**: colorful output telling you what passed (✅ green!) and what failed (❌ red!).
- **Clean Environment Management**: `setup_test_env` and `teardown_test_env` hooks.

## 📥 Installation

- Download the lib and place it in your project's test directory.

  ```bash
  curl -o exit0.sh https://raw.githubusercontent.com/mattmezza/exit0/main/exit0.sh
  ```
- Create your test script (e.g., `my_script.test.sh`).

## 🧑‍💻 Test File Example

Here's how your test file will look:

```bash
#/bin/env bash

source "./exit0.sh"

# Optional: Runs before each scenario
setup_test_env() {
    mkdir -p /tmp/test_project
    echo "Hello World" > /tmp/test_project/greeting.txt
}

# Optional: Runs after all scenarios via run_teardown
teardown_test_env() {
    rm -rf /tmp/test_project
}

scenario "My 'greet' command works correctly"
when_running "/bin/cat /tmp/test_project/greeting.txt"
then_the_exit_code_should_be 0
and_stdout_should_contain "Hello World"

scenario "My 'fail' command exits with an error"
when_running "/bin/false" # A command that always fails
then_the_exit_code_should_be_higher_than 0
and_the_stderr_should_be_empty # 'false' usually doesn't output to stderr

# 👇 Don't forget these at the end of your test file! 👇
run_teardown
report_results
```

## 📝 Assertion Guide

`exit0` gives you a powerful set of assertions to check your CLI's behavior:

Assertion Function                          |What it Tests  |Description|
|-------------------------------------------|---------------|----------------------------------------------|
`when_running "cmd"`                        |execution      |Executes your command and captures all its outputs.|
`scenario "Name"`                           |test block     |Starts a new logical group of related tests.|
`then_the_exit_code_should_be 0`            |exit code      |Checks if the command's exit code is exactly what you expect.|
`then_the_exit_code_should_NOT_be 1`        |exit code      |Confirms the exit code is NOT a specific unexpected value.|
`then_the_exit_code_should_be_higher_than 0`|exit code      |Verifies the exit code is greater than a given number (e.g., failed).|
`then_the_exit_code_should_be_lower_than 2` |exit code      |Verifies the exit code is less than a given number (e.g., successful).|
`then_the_stdout_should_contain "text"`     |stdout         |Asserts that the command's standard output includes a specific string.|
`then_the_stdout_should_NOT_contain "text"` |stdout         |Asserts that the command's standard output DOES NOT include a specific string.|
`then_the_stdout_should_be "exact\noutput"` |stdout         |Asserts the standard output matches a string exactly (including newlines).|
`then_the_stdout_should_NOT_be "exact"`     |stdout         |Asserts the standard output does NOT match a string exactly.|
`then_the_stderr_should_contain "Error"`    |stderr         |Checks if any error output contains a specific string.|
`then_the_stderr_should_be_empty`           |stderr         |Ensures there was no output to standard error.|

## 🔗 Chaining Assertions

You can chain multiple assertions after a single `when_running` call using
`and_the_...` functions (e.g., `and_stdout_should_contain`) for cleaner, more
fluent tests!

## 🔧 Environment Hooks

Manage your test environment like a pro with these lifecycle functions:

Function Name       |When It Runs                                   | What It's For|
|-------------------|-----------------------------------------------|----------------------|
`setup_test_env`    |At the beginning of each scenario.             |Set up temporary files, directories, or environment variables.|
`teardown_test_env` |When `run_teardown` is called (at script end). |Clean up all the temporary resources created during tests.|

Important: Make sure to call `run_teardown` at the very end of your test script to ensure `teardown_test_env` runs!

## 💖 Contributing

We'd love your help! Whether you've found a bug 🐞, have an idea for a new assertion, or want to improve the documentation, feel free to open an Issue or submit a Pull Request!

## 💡 Future Ideas

- Adding support for sending input to commands via `stdin` ⌨️.
- More robust error handling in `when_running` for edge cases.

## 📄 License

`exit0` is open-source and distributed under the MIT License. Use it, share it, improve it!


#### Enjoy testing with `exit0`! 🎉
