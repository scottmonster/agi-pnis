# Bash Pitfalls Catalog
_Entry format: <index> **<canonical name>** _(impact: [high|medium|low]; consensus: [high|medium|low])_ - <concise definition>._

## 1. Expansion, Command Construction, and Pathname Safety

### 1.1 Expansion and argument boundaries
1.1.1 **Quote expansions that should remain one argument** _(impact: high; consensus: high)_ - Use `"$var"` and `"$(command)"` when the expansion is intended to produce one argument. Unquoted parameter and command expansions are subject to word splitting and pathname expansion.

### 1.2 Positional parameters
1.2.1 **Preserve argument boundaries with `"$@"`** _(impact: high; consensus: high)_ - Forward arguments with `"$@"`, not unquoted `$@`, `$*`, or `"$*"`. Inside double quotes, `"$@"` expands each positional parameter as a separate word.

### 1.3 Pathname handling
1.3.1 **Do not parse `ls` or newline-delimited output as filenames** _(impact: high; consensus: high)_ - Do not use constructs such as `for f in $(ls ...)` or otherwise assume filenames are separated by whitespace or newlines. Use shell globs, `find -exec`, or NUL-delimited interfaces.

### 1.4 Pathname and option safety
1.4.1 **Protect operands that begin with `-`** _(impact: high; consensus: high)_ - When filenames or other data may begin with a hyphen, terminate options with `--` where supported, as in `rm -- "$file"`, or make pathnames unambiguous with forms such as `./*`.

### 1.5 Command construction
1.5.1 **Use arrays for dynamically constructed argument lists** _(impact: high; consensus: high)_ - Store a command's arguments in an array and invoke it with `"${args[@]}"`. Do not build a single string containing shell quotes or escaped spaces and expect those characters to become shell syntax when the variable expands.

### 1.6 Multi-stage evaluation
1.6.1 **Avoid `eval` for data-driven command construction** _(impact: high; consensus: high)_ - Do not pass data, especially untrusted data, through `eval` merely to build commands, indirect assignments, or argument lists. Prefer arrays, associative arrays, namerefs where safe, or explicit dispatch.
1.6.2 **Do not accidentally execute command-substitution output** _(impact: high; consensus: high)_ - `$(command)` produces text. Placing that expansion where Bash expects a command, such as `$(get_command)`, causes the resulting text to be split and used as a command and arguments. Do this only when execution is explicitly intended.

### 1.7 Arithmetic evaluation
1.7.1 **Treat arithmetic contexts as evaluation contexts** _(impact: high; consensus: high)_ - Validate untrusted values before inserting them into `$((...))`, `((...))`, array subscripts, or other arithmetic contexts. Bash arithmetic performs recursive variable evaluation and can encounter command substitutions through crafted expressions.

### 1.8 Command construction
1.8.1 **Pass `find -exec sh -c` operands as arguments** _(impact: high; consensus: high)_ - Do not interpolate `{}` directly into the shell program supplied to `find -exec sh -c`. Pass filenames after the script and access them through positional parameters, such as `sh -c 'for f do ...; done' sh {} +`.

### 1.9 Pathname transport
1.9.1 **Use NUL-safe interfaces for arbitrary pathnames** _(impact: high; consensus: high)_ - For pathname streams, prefer `find -exec ... {} +` or NUL-delimited pairs such as `find -print0` with `xargs -0` or `read -d ''`.

### 1.10 Filesystem safety
1.10.1 **Create temporary resources atomically** _(impact: high; consensus: high)_ - Do not create predictable temporary paths such as `/tmp/script.$$`. Use `mktemp`, preferably a private temporary directory where multiple related files are needed, and arrange cleanup.

### 1.11 Filesystem state
1.11.1 **Check `cd` before operating on relative paths** _(impact: high; consensus: high)_ - Use forms such as `cd -- "$dir" || exit` or `cd -- "$dir" || return` before commands whose meaning depends on the directory change.

### 1.12 Filesystem mutation
1.12.1 **Fail closed on empty destructive path variables** _(impact: high; consensus: high)_ - Before destructive commands, validate required paths and use defensive expansion such as `${dir:?}` where appropriate, together with quoting and option termination.

## 2. File, Pipeline, and Input Safety

### 2.1 Redirection and data integrity
2.1.1 **Do not read and overwrite the same file through one pipeline** _(impact: high; consensus: high)_ - Avoid constructs where a command reads a file while shell redirection simultaneously opens that same file for output. Write to a separate temporary file and replace the original after success.
2.1.2 **Remember that output redirection truncates before command execution** _(impact: high; consensus: high)_ - `command > file` causes Bash to open and normally truncate `file` as part of setting up the command. For important transformations, write to another file and replace the target only after success.

### 2.2 Privilege boundaries
2.2.1 **`sudo` does not elevate shell redirections** _(impact: high; consensus: high)_ - `sudo command > privileged-file` runs `command` through `sudo`, but the invoking shell performs `> privileged-file`. Use an appropriate privileged writer such as `sudo tee` or explicitly run the required shell operation under the elevated context.

### 2.3 Remote execution
2.3.1 **Account for local expansion in SSH command strings** _(impact: high; consensus: high)_ - Commands sent through `ssh` commonly pass through a local shell and then a remote shell. Quote and structure them with both parsing stages in mind rather than interpolating arbitrary local values into remote shell source.
2.3.2 **Quote remote here-document delimiters when expansion belongs remotely** _(impact: high; consensus: high)_ - When feeding a script to `ssh` with a here-document, quote the local delimiter if variables and command substitutions should remain intact until the remote shell receives them.

### 2.4 Pipelines and subshells
2.4.1 **Do not expect pipeline loop mutations to survive** _(impact: high; consensus: high)_ - In normal Bash execution, pipeline components execute in subshell environments, so assignments inside constructs such as `producer | while read ...` generally do not modify the parent shell. Prefer redirection or carefully designed process substitution when parent-state mutation is needed.

### 2.5 Pipeline status
2.5.1 **Do not assume pipeline success means every stage succeeded** _(impact: high; consensus: high)_ - Without `pipefail`, a pipeline's status is normally the status of its final command. Where upstream failure matters, inspect `PIPESTATUS`, use an appropriate `pipefail` scope, or redesign the operation to propagate status explicitly.

### 2.6 Asynchronous execution
2.6.1 **`&` does not report the background command's final status** _(impact: high; consensus: high)_ - Starting a command with `&` only reports successful asynchronous launch semantics. Save its PID and use `wait` when the eventual success or failure matters.

### 2.7 Process substitution
2.7.1 **Do not assume process substitution contributes to command status** _(impact: high; consensus: high)_ - Commands in `<(...)` or `>(...)` run asynchronously and their failures are not automatically represented by the status of the surrounding command. Arrange explicit synchronization or status reporting when their success matters.

### 2.8 Exit status handling
2.8.1 **Separate declaration from status-sensitive command substitution** _(impact: high; consensus: high)_ - Avoid `local x=$(command)`, `export x=$(command)`, and similar constructs when `command` status matters. Declare first, then assign: `local x; x=$(command)`.

### 2.9 Shell data model
2.9.1 **Do not store arbitrary binary data in Bash variables** _(impact: high; consensus: high)_ - Bash variables cannot represent embedded NUL bytes. Keep arbitrary binary data in files, pipes, or other byte-oriented tools rather than shell variables.

### 2.10 Input parsing
2.10.1 **Use `IFS= read -r` for literal text lines** _(impact: high; consensus: high)_ - For line-oriented input where whitespace and backslashes are data, use `while IFS= read -r line; do ...; done`.

### 2.11 Input stream ownership
2.11.1 **Prevent commands inside `while read` from stealing loop input** _(impact: high; consensus: high)_ - Commands such as `ssh` that read standard input can consume data intended for the surrounding `while read` loop. Redirect their input, use options such as `ssh -n`, or dedicate another file descriptor to the loop.

## 3. Script Boundaries and Runtime Setup

### 3.1 Here documents
3.1.1 **Quote here-document delimiters for literal bodies** _(impact: high; consensus: high)_ - Use a quoted delimiter such as `<<'EOF'` when the here-document body should be literal. An unquoted delimiter permits parameter expansion, command substitution, and arithmetic expansion in the body.

### 3.2 Interpreter selection
3.2.1 **Declare the interpreter that matches the script language** _(impact: high; consensus: high)_ - Scripts using Bash syntax should identify Bash rather than `sh`; scripts intended for POSIX `sh` should avoid Bash-specific constructs.

### 3.3 Interpreter invocation
3.3.1 **Do not run a Bash script as `sh script`** _(impact: high; consensus: high)_ - If a script declares Bash, execute it directly or run it with `bash script`. Calling `sh script` explicitly selects `sh` behavior instead of honoring the script's Bash interpreter declaration.

### 3.4 File descriptors
3.4.1 **Redirection order is significant** _(impact: high; consensus: high)_ - Redirections are processed from left to right. `command >file 2>&1` sends both streams to the file, while `command 2>&1 >file` duplicates stderr to the previous stdout before stdout is redirected.

### 3.5 Output formatting
3.5.1 **Never use uncontrolled text as a `printf` format string** _(impact: high; consensus: high)_ - Prefer `printf '%s\n' "$value"` rather than `printf "$value"`. The first argument to `printf` is a format string, not ordinary text.

### 3.6 Arrays
3.6.1 **Quote `"${array[@]}"` to preserve elements** _(impact: high; consensus: high)_ - When passing every array element as arguments, use `"${array[@]}"`. Unquoted expansion permits each element to undergo additional word splitting and pathname expansion.

### 3.7 Arrays and parsing
3.7.1 **Do not populate arrays with unquoted command substitution** _(impact: high; consensus: high)_ - Avoid `array=( $(command) )` when command output represents records. Use `mapfile -t array < <(command)` for line records, or an explicit delimiter-aware reader for another format.

### 3.8 Code and data boundaries
3.8.1 **Do not `source` untrusted configuration files** _(impact: high; consensus: high)_ - `source file` and `. file` execute the file as shell code in the current shell. Use a data format and parser if the file is supposed to contain untrusted configuration data rather than executable code.

### 3.9 Command lookup and sourcing
3.9.1 **Use an explicit path when sourcing a specific file** _(impact: high; consensus: high)_ - When file identity matters, source `./file`, an absolute path, or a deliberately resolved path instead of relying on `source file`. Bash can search `PATH`, with additional behavior depending on mode and options.

### 3.10 Startup environment
3.10.1 **Account for `BASH_ENV` in non-interactive execution** _(impact: high; consensus: high)_ - When Bash executes a non-interactive shell script, `BASH_ENV` can name a file to source before the script. Security-sensitive execution should not assume a clean startup environment when hostile environment variables are possible.

### 3.11 Command resolution
3.11.1 **Control command lookup in security-sensitive scripts** _(impact: high; consensus: high)_ - Bash searches `PATH` for external commands that contain no slash. In privileged or otherwise security-sensitive execution, use a trusted `PATH` or explicit executable paths rather than inheriting an uncontrolled search path.

### 3.12 Privilege boundaries
3.12.1 **Remember that globs are expanded before `sudo`** _(impact: high; consensus: high)_ - In `sudo command /protected/*`, the invoking shell expands `*` before `sudo` runs. If the current user cannot traverse the directory, or if matching semantics differ from what the privileged command needs, perform pathname discovery inside the privileged context instead.

### 3.13 Error handling
3.13.1 **Do not treat `set -e` as complete error handling** _(impact: high; consensus: medium)_ - `set -e` can be useful as a guardrail, but Bash deliberately suppresses or changes its behavior in numerous syntactic contexts. Explicitly handle failures at operations whose success is essential rather than assuming every nonzero status terminates execution.

## 4. Error Semantics and Conditional Logic

### 4.1 Error handling semantics
4.1.1 **`errexit` changes inside conditions and command substitutions** _(impact: high; consensus: medium)_ - Functions invoked as conditions, commands in `if`, `while`, `until`, `&&`, `||`, and other tested contexts are subject to `errexit` exceptions. Bash also normally clears `-e` in command-substitution subshells unless `inherit_errexit` or applicable POSIX behavior changes it.

### 4.2 Pipeline status
4.2.1 **Do not enable `pipefail` blindly around early-exiting consumers** _(impact: high; consensus: medium)_ - `pipefail` makes upstream failures visible, but consumers such as `grep -q` may intentionally exit after finding enough input, causing an upstream producer to receive SIGPIPE and return nonzero. Scope `pipefail` deliberately and understand each pipeline's expected termination behavior.

### 4.3 Traps and error handling
4.3.1 **Do not treat `ERR` as a universal exception trap** _(impact: high; consensus: medium)_ - The `ERR` trap is not invoked for several of the same contexts exempted from `errexit`, including many conditions, intermediate pipeline commands, and commands whose status is inverted.

### 4.4 Associative arrays and evaluation
4.4.1 **Treat associative-array subscripts as version-sensitive evaluation contexts** _(impact: high; consensus: medium)_ - Bash has had multiple historical behaviors involving repeated evaluation of associative-array subscripts in arithmetic and related contexts. Avoid placing untrusted keys into such expressions, and verify idioms against the Bash versions you support.

### 4.5 Command substitution
4.5.1 **Command substitution removes trailing newlines** _(impact: medium; consensus: high)_ - `$(command)` removes all trailing newline characters from the captured output. Do not use ordinary command substitution when those final newlines are semantically significant.

### 4.6 Redirection semantics
4.6.1 **Here strings append a newline** _(impact: medium; consensus: high)_ - `command <<< "$value"` supplies the expanded value followed by a newline. Use another input mechanism when exact stream contents are required.

### 4.7 Conditional expressions
4.7.1 **Quote variables used with `[ ... ]`** _(impact: medium; consensus: high)_ - With the traditional `test` or `[` command, quote variable operands such as `[ -n "$value" ]` and `[ "$a" = "$b" ]`.
4.7.2 **Prefer `[[ ... ]]` for Bash-native string tests** _(impact: medium; consensus: high)_ - In code explicitly targeting Bash, `[[ ... ]]` avoids word splitting and pathname expansion of ordinary operands and provides clearer pattern and regex operators. Use `[` when POSIX portability is a requirement.

### 4.8 Pattern matching
4.8.1 **Quote the right side of `[[ = ]]` for literal equality** _(impact: medium; consensus: high)_ - In `[[ $value = $pattern ]]`, an unquoted right-hand operand is interpreted as a shell pattern. Write `[[ $value = "$literal" ]]` when literal equality is intended.

### 4.9 Regular expressions
4.9.1 **Do not quote a regex variable when regex matching is intended** _(impact: medium; consensus: high)_ - With `[[ string =~ regex ]]`, quoting the entire regex expansion makes the quoted portion literal. Use an unquoted regex variable within `[[ ]]` when its content is deliberately an extended regular expression.
4.9.2 **Distinguish invalid regex from no regex match** _(impact: medium; consensus: high)_ - `[[ value =~ regex ]]` returns 0 for match, 1 for no match, and 2 when the regular expression itself is syntactically invalid.
4.9.3 **Copy `BASH_REMATCH` before another regex match** _(impact: medium; consensus: high)_ - `BASH_REMATCH` is maintained by Bash for `=~` results and is not a normal function-local result object. Copy captures you need before another match can overwrite them.

### 4.10 Conditional expressions
4.10.1 **Use arithmetic comparison for numbers** _(impact: medium; consensus: high)_ - Do not use string ordering such as `[[ $x > 7 ]]` when numeric comparison is intended. Use arithmetic syntax such as `(( x > 7 ))` or numeric test operators.

## 5. Conditional, Status, Parameter, and Globbing Semantics

### 5.1 Conditional expressions
5.1.1 **Avoid `-a` and `-o` inside `test` expressions** _(impact: medium; consensus: high)_ - Instead of complex `[ ... -a ... ]` or `[ ... -o ... ]` expressions, combine separate tests with shell `&&` and `||`, or use `[[ ... ]]` in Bash.
5.1.2 **`[ false ]` is true** _(impact: medium; consensus: high)_ - A one-argument `test` is true when its argument is a nonempty string. Therefore `[ false ]`, `[ 0 ]`, and similar constructs are true. Run commands such as `false` directly or perform an explicit comparison.

### 5.2 Exit status handling
5.2.1 **Test a command by running it** _(impact: medium; consensus: high)_ - Prefer `if command; then ...` over running a command, inspecting `$?`, and then branching. Do not place a command name inside `[ ... ]` expecting it to be executed.

### 5.3 Control flow
5.3.1 **`A && B || C` is not a general ternary expression** _(impact: medium; consensus: high)_ - Do not assume `A && B || C` means exactly `if A; then B; else C; fi`. If `A` succeeds but `B` fails, `C` also runs.

### 5.4 Exit status handling
5.4.1 **Capture `$?` before running anything else** _(impact: medium; consensus: high)_ - If `$?` must be inspected, save it immediately after the relevant command. Prefer testing the command directly when possible.

### 5.5 Pipeline status
5.5.1 **Capture `PIPESTATUS` immediately** _(impact: medium; consensus: high)_ - Bash's `PIPESTATUS` array describes the most recently executed foreground pipeline. Copy it before running another command or pipeline.

### 5.6 Arithmetic status
5.6.1 **Remember that `((i++))` can return failure** _(impact: medium; consensus: high)_ - Arithmetic commands return success when the resulting expression value is nonzero. Consequently `((i++))` returns status 1 when `i` was initially zero. Use a form such as `((++i))` when that status distinction matters, or otherwise neutralize the status deliberately.

### 5.7 Parameter expansion
5.7.1 **Distinguish unset from empty in parameter defaults** _(impact: medium; consensus: high)_ - `${var:-word}` substitutes `word` when `var` is unset or empty, while `${var-word}` substitutes only when it is unset. The same colon distinction applies to related parameter operators.

### 5.8 Parameter expansion and patterns
5.8.1 **Quote literal variables inside parameter-removal patterns** _(impact: medium; consensus: high)_ - In expressions such as `${value%$suffix}`, the suffix expansion participates as a pattern. Use the appropriate inner quoting, such as `${value%"$suffix"}`, when the expanded text should be treated literally.

### 5.9 Pattern matching
5.9.1 **Remember that `case` operands are patterns** _(impact: medium; consensus: high)_ - An expanded value in a `case` pattern position remains pattern syntax unless quoted appropriately. Quote an expansion when its content should be matched literally.

### 5.10 Filename expansion
5.10.1 **Handle unmatched globs explicitly** _(impact: medium; consensus: high)_ - By default, an unmatched Bash glob normally remains unchanged as literal text. Decide explicitly whether zero matches should produce no arguments, an error, or literal text.
5.10.2 **Scope `nullglob` and `failglob` deliberately** _(impact: medium; consensus: high)_ - `nullglob` removes unmatched patterns, while `failglob` turns them into an expansion error. Enable such options only where their behavior is intended, often in a subshell or tightly scoped section.
5.10.3 **Decide explicitly whether globs should include dotfiles** _(impact: medium; consensus: high)_ - Ordinary `*` does not match leading-dot names. Use `dotglob` or another deliberate technique when hidden entries must be included.

## 6. Environment, Parsing, Filesystem Tests, and Arrays

### 6.1 Shell environment state
6.1.1 **Avoid hidden dependence on `GLOBIGNORE`** _(impact: medium; consensus: high)_ - `GLOBIGNORE` changes filename expansion behavior and has interactions with dotfile matching. Scripts should set or neutralize such state deliberately when exact glob semantics matter.

### 6.2 Parsing and shell options
6.2.1 **Enable `extglob` before parsing constructs that use it** _(impact: medium; consensus: high)_ - Extended glob syntax can affect parsing. Enable `extglob` before Bash parses function bodies or compound commands containing that syntax.

### 6.3 Locale and pattern matching
6.3.1 **Control locale when character ranges require ASCII semantics** _(impact: medium; consensus: high)_ - Bracket ranges and character classes can depend on locale. Use an appropriate locale such as `LC_ALL=C` when bytewise ASCII ordering is specifically required rather than assuming `[A-Z]` always has ASCII behavior.

### 6.4 Shell and utility boundaries
6.4.1 **Quote patterns intended for another utility** _(impact: medium; consensus: high)_ - Quote patterns supplied to tools such as `find`, `grep`, and `tr` when those tools, rather than Bash, should interpret them.

### 6.5 Conditional expressions
6.5.1 **Do not pass an expanding glob to one `test -e` expression** _(impact: medium; consensus: high)_ - `[ -e directory/* ]` is unsafe as an existence test because zero, one, and multiple glob matches all produce different argument structures. Use an array, loop, or deliberate glob-option technique.
6.5.2 **`[[ -e pattern* ]]` does not perform pathname expansion** _(impact: medium; consensus: high)_ - Do not expect a glob supplied as a file operand inside `[[ ]]` to enumerate matching files. Expand the pattern in a context where filename expansion actually occurs, then test the resulting paths.

### 6.6 Filesystem tests
6.6.1 **`-e` is false for a dangling symlink** _(impact: medium; consensus: high)_ - `[[ -e path ]]` follows the symlink target, so a broken symbolic link does not satisfy it. Use `-L` or `-h` when the existence of the link object itself is what matters.

### 6.7 Record parsing
6.7.1 **Do not treat `IFS=, read` as a CSV parser** _(impact: medium; consensus: high)_ - `IFS` field splitting can handle simple delimiter-separated records but does not implement CSV quoting and escaping rules, and Bash splitting has edge cases around empty fields. Use a real CSV parser for CSV.

### 6.8 Shell environment state
6.8.1 **Preserve the distinction between unset and empty `IFS`** _(impact: medium; consensus: high)_ - Saving `IFS` as `oldIFS=$IFS` cannot record whether it was originally unset rather than merely empty. Prefer `local IFS` in a function or a subshell when temporarily changing it.

### 6.9 Input parsing
6.9.1 **Handle an unterminated final input line when it matters** _(impact: medium; consensus: high)_ - `read` can assign the final partial line and still return failure if it lacks a terminating newline. When such input is valid, use a loop condition that also processes a nonempty final value.

### 6.10 Arrays and arithmetic
6.10.1 **Indexed-array subscripts are arithmetic expressions** _(impact: medium; consensus: high)_ - `array[index]` does not require `index` to be a simple decimal literal. Indexed-array subscripts are evaluated arithmetically. Validate externally supplied index values rather than assuming they are inert strings.

### 6.11 Arrays
6.11.1 **Bash indexed arrays are sparse** _(impact: medium; consensus: high)_ - `${#array[@]}` is the number of assigned elements, not necessarily one more than the largest index. Iterate `"${!array[@]}"` when actual indices matter.
6.11.2 **`${array}` means element zero, not the whole array** _(impact: medium; consensus: high)_ - Referencing an indexed array without `[@]` or `[*]` behaves like a reference to subscript zero. Use `"${array[@]}"` when all elements are intended.

## 7. Arrays, Arithmetic, Expansion, and Functions

### 7.1 Arrays and pathname expansion
7.1.1 **Quote array subscripts passed to `unset`** _(impact: medium; consensus: high)_ - Use `unset 'array[index]'` or another safely quoted form rather than leaving brackets exposed to filename expansion.

### 7.2 Associative arrays
7.2.1 **Do not rely on associative-array iteration order** _(impact: medium; consensus: high)_ - Bash associative arrays do not provide an insertion-order contract. Maintain a separate ordered key list or sort keys when deterministic ordering is required.

### 7.3 Shell data model
7.3.1 **Bash does not provide true multidimensional arrays** _(impact: medium; consensus: high)_ - Do not model substantial nested structures by assuming Bash arrays nest like arrays or maps in general-purpose languages. Bash array elements are strings, with one-dimensional indexed and associative collections.

### 7.4 Arithmetic evaluation
7.4.1 **Leading zeroes invoke octal arithmetic** _(impact: medium; consensus: high)_ - Bash integer constants with a leading `0` are interpreted as octal. Validate decimal input or deliberately convert it before arithmetic when values such as `08` or `09` may occur.
7.4.2 **Use `10#` carefully for signed decimal input** _(impact: medium; consensus: high)_ - Prefixing a numeric magnitude with `10#` can force decimal interpretation, but blindly constructing `10#$value` is not a complete solution for signed input. Validate the format and handle the sign separately when necessary.

### 7.5 Arithmetic limits
7.5.1 **Bash arithmetic overflow is not checked** _(impact: medium; consensus: high)_ - Bash performs fixed-width integer arithmetic using the implementation's largest integer type and does not provide general overflow detection. Use another mechanism when arithmetic range is correctness-critical.
7.5.2 **Bash arithmetic is integer-only** _(impact: medium; consensus: high)_ - Shell arithmetic does not provide native floating-point arithmetic. Use an appropriate tool such as `awk`, `bc`, or a general-purpose language when decimal arithmetic is required.

### 7.6 Expansion ordering
7.6.1 **Brace expansion does not use parameter expansion for its bounds** _(impact: medium; consensus: high)_ - Constructs such as `{1..$n}` do not create a runtime range from `$n`, because brace expansion happens before parameter expansion. Use an arithmetic loop when bounds are dynamic.

### 7.7 Expansion scale
7.7.1 **Avoid huge brace expansions** _(impact: medium; consensus: high)_ - Brace expansion creates the expanded words before executing the command. For large numeric ranges, use an arithmetic loop or streaming mechanism instead.

### 7.8 Function scope
7.8.1 **Bash function locals use dynamic scope** _(impact: medium; consensus: high)_ - A local variable in a Bash function is visible to functions called from that function unless they shadow it. Do not assume lexical-scope behavior from languages such as Python or JavaScript.
7.8.2 **`declare` inside a function is local by default** _(impact: medium; consensus: high)_ - Within a function, `declare` creates a local variable unless an option such as `-g` explicitly requests global scope.

### 7.9 Function contracts
7.9.1 **Function status defaults to the last command's status** _(impact: medium; consensus: high)_ - If a Bash function reaches its end without an explicit `return`, its status is the status of its last executed command. Use explicit status handling when the function's success contract matters.

### 7.10 Positional parameters
7.10.1 **Positional parameters above 9 require braces** _(impact: medium; consensus: high)_ - Use `${10}`, `${11}`, and so on. `$10` is parsed as `$1` followed by literal `0`.

## 8. Functions, Traps, and Process Environments

### 8.1 Option parsing
8.1.1 **Reset or localize `OPTIND` before reparsing options** _(impact: medium; consensus: high)_ - `getopts` uses `OPTIND` to track parser position. Functions or repeated parsing passes should deliberately initialize or localize it as appropriate.

### 8.2 Function contracts
8.2.1 **Do not return data through shell exit status** _(impact: medium; consensus: high)_ - Shell command and function status is a small numeric success/failure channel, conventionally 0 through 255. Return substantive data through stdout, variables, arrays, or another explicit interface.

### 8.3 Traps
8.3.1 **Quote trap bodies for the intended expansion time** _(impact: medium; consensus: high)_ - A trap body written with double quotes can expand variables or substitutions when `trap` is installed. Single-quote the trap command when those expansions should occur when the signal or exit event happens.

### 8.4 Traps and function execution
8.4.1 **Trap inheritance is option-dependent** _(impact: medium; consensus: high)_ - `ERR`, `DEBUG`, and `RETURN` traps are not uniformly inherited by functions, command substitutions, and subshells. Bash options such as `errtrace` and `functrace` affect inheritance.

### 8.5 Signals
8.5.1 **SIGKILL and SIGSTOP cannot be trapped** _(impact: medium; consensus: high)_ - Do not design mandatory cleanup or data-integrity guarantees around traps for `KILL` or `STOP`; those signals cannot be caught by the shell.
8.5.2 **Prefer signal names over numeric signal values** _(impact: medium; consensus: high)_ - Use symbolic names such as `TERM`, `INT`, and `HUP` rather than relying on signal numbers where portability matters.

### 8.6 File descriptors
8.6.1 **Closing stderr is not equivalent to discarding it** _(impact: medium; consensus: high)_ - `2>&-` closes file descriptor 2, while `2>/dev/null` leaves it open and directs output to a sink. Use `/dev/null` when the goal is merely to suppress output.
8.6.2 **Close dynamically allocated file descriptors when finished** _(impact: medium; consensus: high)_ - Bash redirections such as `exec {fd}>file` allocate a descriptor and can keep it open beyond one command. Close persistent descriptors explicitly when their lifetime ends.

### 8.7 Process execution
8.7.1 **`exec` replaces the shell on success** _(impact: medium; consensus: high)_ - `exec command` does not launch a child and then resume the script. On success, the current shell process becomes the target program.

### 8.8 Evaluation order
8.8.1 **Temporary environment assignments do not affect same-command shell expansion** _(impact: medium; consensus: high)_ - In `VAR=new command "$VAR"`, the `$VAR` expansion is performed by the shell before the temporary environment assignment is made available to `command`. Separate the assignment when the new value must also affect shell-side expansion.

### 8.9 Execution environments
8.9.1 **Use subshell grouping when temporary state should not escape** _(impact: medium; consensus: high)_ - `( commands )` runs in a subshell environment, while `{ commands; }` normally runs in the current shell. A common idiom is `(cd dir && commands)` when directory or variable changes should be temporary.

### 8.10 Pipelines and shell options
8.10.1 **Do not depend accidentally on `lastpipe`** _(impact: medium; consensus: high)_ - With `lastpipe` enabled and job control disabled, Bash can execute the final foreground pipeline component in the current shell rather than a subshell. Code should either deliberately depend on this configured behavior or avoid the dependency.

### 8.11 Asynchronous execution
8.11.1 **Save `$!` immediately for each asynchronous job** _(impact: medium; consensus: high)_ - `$!` identifies the most recently started asynchronous process or applicable process substitution. Store it before launching another asynchronous operation.

## 9. Script Execution, Utilities, and Environment

### 9.1 Asynchronous execution
9.1.1 **Background commands may receive `/dev/null` as stdin** _(impact: medium; consensus: high)_ - When job control is not active, Bash can redirect standard input for an asynchronous command without an explicit input redirection from `/dev/null`. Redirect input deliberately when a background job requires it.

### 9.2 Script location
9.2.1 **Use `BASH_SOURCE` rather than `$0` for the currently sourced Bash file** _(impact: medium; consensus: high)_ - When Bash code needs the pathname associated with a sourced file or function stack, use the `BASH_SOURCE` array. `$0` identifies the shell or top-level script invocation and does not change simply because another file was sourced.

### 9.3 Process identity
9.3.1 **Use `BASHPID` when the current Bash process ID is required** _(impact: medium; consensus: high)_ - `$$` identifies the invoking shell process and can remain unchanged in subshell constructs. `BASHPID` identifies the current Bash process and therefore differs in relevant subshell situations.

### 9.4 Sourcing and scope
9.4.1 **Remember that sourcing mutates the current shell** _(impact: medium; consensus: high)_ - `source` and `.` execute commands in the current shell rather than in an isolated child. Use a subshell when you intentionally want the sourced code's variable, directory, option, or trap changes isolated.

### 9.5 Interpreter selection
9.5.1 **Keep the shebang at the beginning of the file** _(impact: medium; consensus: high)_ - The interpreter line must be the file's first line in the required `#!` position. Do not place comments or blank lines before it.

### 9.6 Source representation
9.6.1 **Keep shell scripts free of CRLF line endings** _(impact: medium; consensus: high)_ - Shell scripts intended for Unix execution should use LF line endings. A carriage return from CRLF can become part of tokens, delimiters, or the interpreter pathname.

### 9.7 Interpreter portability
9.7.1 **Do not assume portable multi-argument shebang parsing** _(impact: medium; consensus: high)_ - Kernel shebang handling historically does not provide a portable way to express arbitrary multiple interpreter arguments. Keep interpreter invocation simple unless the deployment platforms and features such as `env -S` are explicitly controlled.

### 9.8 Parsing and reusable commands
9.8.1 **Prefer functions to aliases in scripts** _(impact: medium; consensus: high)_ - Aliases are primarily an interactive convenience. Their expansion is parse-time, is normally disabled in non-interactive shells unless configured otherwise, and does not behave like a parameterized function.

### 9.9 Command lookup
9.9.1 **Use `command -v` for shell-aware command discovery** _(impact: medium; consensus: high)_ - Prefer `command -v name` when a script needs to determine what the shell would resolve for a command name. Avoid depending on the nonstandard external `which` utility.

### 9.10 Output formatting
9.10.1 **Prefer `printf` to `echo` for predictable output** _(impact: medium; consensus: high)_ - Use `printf '%s\n' "$value"` when exact portable behavior matters. `echo` has historically variable handling of `-n`, backslashes, and implementation-specific options.

### 9.11 Utility integration
9.11.1 **Quote `tr` ranges and decide their locale semantics** _(impact: medium; consensus: high)_ - Do not write unquoted shell-looking forms such as `tr [A-Z] [a-z]`. Quote the operands, and use character classes or a controlled locale according to the intended character semantics.

### 9.12 Process discovery
9.12.1 **Do not identify processes with `ps | grep`** _(impact: medium; consensus: high)_ - Prefer tracking the PID of the process you launched, or use a purpose-built interface such as `pgrep` when process-name lookup is genuinely required.

### 9.13 Environment-dependent directory resolution
9.13.1 **Do not export `CDPATH` casually** _(impact: medium; consensus: high)_ - `CDPATH` changes how Bash resolves relative operands to `cd` and can cause successful `cd` operations to print the selected directory. Scripts should avoid inheriting or exporting a surprising `CDPATH` when deterministic relative-directory behavior matters.

## 10. Shell State, Syntax, and Compatibility

### 10.1 Shell option state
10.1.1 **Treat shell option changes as shared state** _(impact: medium; consensus: high)_ - Options changed with `set` or `shopt` can affect later code in the same shell, including callers of sourced files and functions. Use subshells or explicit save-and-restore logic when an option is intended to be local to one operation.

### 10.2 Regular expressions
10.2.1 **Bash `=~` uses extended regular expressions, not PCRE** _(impact: medium; consensus: high)_ - Patterns used by `[[ value =~ regex ]]` follow Bash's POSIX extended regular-expression interface. Do not assume constructs from PCRE, Perl, or other regex dialects have the same meaning.

### 10.3 Error handling
10.3.1 **Do not assume `set -u` is universally beneficial strictness** _(impact: medium; consensus: medium)_ - `set -u` catches some accidental references to unset variables, but unset values are also a legitimate part of shell semantics and historical Bash versions have additional array-related edge cases. Use it deliberately rather than assuming every script should enable it.

### 10.4 File output safety
10.4.1 **Treat `noclobber` as a guardrail, not a complete write strategy** _(impact: medium; consensus: medium)_ - `set -C` or `set -o noclobber` prevents ordinary `>` redirection from replacing an existing regular file, but `>|` overrides it and the option does not replace explicit transactional or atomic-write design.

### 10.5 Parallel execution
10.5.1 **Parallel `xargs` jobs can interleave output** _(impact: medium; consensus: medium)_ - When using `xargs -P`, do not assume multiple workers can safely write arbitrary multi-part records to a shared stdout stream without coordination. Buffer per-job output or serialize publication when record integrity matters.

### 10.6 Variable attributes and evaluation
10.6.1 **`declare -i` turns assignments into arithmetic evaluation** _(impact: medium; consensus: medium)_ - Integer-attributed variables cause assigned values to be evaluated as arithmetic expressions. Avoid feeding uncontrolled strings into `declare -i` variables, and prefer explicit arithmetic where hidden evaluation would be surprising.

### 10.7 Indirection
10.7.1 **Validate names before using namerefs for indirect assignment** _(impact: medium; consensus: medium)_ - `declare -n` allows one variable to refer to another by name. When the target name originates outside trusted code, validate it and constrain which variables may be referenced.

### 10.8 Command substitution syntax
10.8.1 **Prefer `$(...)` to backtick command substitution** _(impact: low; consensus: high)_ - Both forms are supported, but prefer `$(command)` for new code. It nests directly and has clearer quoting and escaping rules than legacy backticks.

### 10.9 Tilde expansion
10.9.1 **A quoted tilde does not perform tilde expansion** _(impact: low; consensus: high)_ - `"~/file"` contains a literal tilde. Use `"$HOME/file"` when a home-directory path must remain quoted.

### 10.10 Assignment and portability
10.10.1 **Separate assignment and export when tilde portability matters** _(impact: low; consensus: high)_ - Shells differ historically in whether a tilde in forms such as `export var=~/dir` receives assignment-context treatment. `var=$HOME/dir; export var` is unambiguous.

### 10.11 Here documents
10.11.1 **`<<-` strips tabs, not arbitrary indentation** _(impact: low; consensus: high)_ - The `<<-` here-document form strips leading tab characters from the body and delimiter. It does not generally strip spaces used for indentation.

### 10.12 Lexical syntax
10.12.1 **Nothing may follow a line-continuation backslash** _(impact: low; consensus: high)_ - A backslash continues a physical line only when it immediately precedes the newline. Trailing spaces after the backslash prevent that interpretation.
10.12.2 **Comments and backslash continuation interact poorly** _(impact: low; consensus: high)_ - Do not insert a comment as though it were an invisible item in the middle of a backslash-continued command. Structure the command differently or move the explanatory comment.

## 11. Command Behavior, Portability, and Aliases

### 11.1 Command resolution
11.1.1 **`time` may be a shell reserved word rather than the external utility** _(impact: low; consensus: high)_ - Bash has a `time` reserved word that can time pipelines and has shell-specific formatting behavior. If a script specifically requires an external `time` implementation and its options, invoke that implementation deliberately.

### 11.2 Legacy utility idioms
11.2.1 **Prefer Bash arithmetic and parameter expansion to `expr`** _(impact: low; consensus: high)_ - In Bash-specific code, prefer `$((...))`, `${#value}`, and appropriate shell constructs over spawning or invoking `expr` for ordinary arithmetic and string-length work.

### 11.3 Function execution boundaries
11.3.1 **Shell functions are not ordinary external executables** _(impact: low; consensus: high)_ - A Bash function exists in shell state and cannot simply be invoked by an unrelated process as though it were a file in `PATH`. Use an executable script when behavior must naturally cross process or privilege boundaries.

### 11.4 Parameter expansion syntax
11.4.1 **Separate a negative substring offset from `:`** _(impact: low; consensus: high)_ - Write forms such as `${value: -1}` when using a negative substring offset. Without separation, `:-` is parsed as the default-value parameter operator.

### 11.5 Arrays
11.5.1 **Negative indexed-array subscripts count from the end** _(impact: low; consensus: high)_ - Bash accepts negative indexed-array subscripts in relevant contexts, interpreting them relative to one greater than the maximum assigned index. Do not assume a negative subscript is automatically an error.
11.5.2 **Commas are not separators in ordinary Bash array assignments** _(impact: low; consensus: high)_ - Bash compound array assignments separate words according to shell syntax, not comma-list syntax. A comma written into an element is normally part of the element.

### 11.6 Portability
11.6.1 **`$(<file)` is Bash-specific shorthand** _(impact: low; consensus: high)_ - Bash supports `$(<file)` as an optimized way to read a file through command substitution. Do not use it in code that must run under shells that do not implement the extension.
11.6.2 **Process substitution is not portable POSIX `sh`** _(impact: low; consensus: high)_ - `<(...)` and `>(...)` are Bash extensions rather than portable POSIX shell syntax. Use pipes, temporary files, or explicit descriptors when POSIX-shell portability is required.
11.6.3 **Here strings are not portable POSIX `sh`** _(impact: low; consensus: high)_ - The `<<<` here-string operator is a Bash feature and should not appear in scripts whose interpreter contract is portable POSIX `sh`.
11.6.4 **Prefer `.` to `source` only when POSIX portability is required** _(impact: low; consensus: high)_ - Bash supports both `source file` and `. file`; POSIX specifies the dot command. Bash-targeted code may use either, but portable shell libraries should use `.` and account for its lookup rules.

### 11.7 Aliases
11.7.1 **Do not expect an alias to accept function-style parameters** _(impact: low; consensus: high)_ - Aliases perform lexical replacement rather than defining callable parameterized routines. Use a function when reusable behavior needs positional arguments or structured control flow.

### 11.8 Aliases and parsing
11.8.1 **Alias definitions may not take effect inside the same parsed compound command** _(impact: low; consensus: high)_ - Bash reads complete compound constructs before executing them, while alias expansion happens during parsing. An alias defined inside such a construct may therefore not affect later text in that already-parsed construct.

### 11.9 Version-specific input behavior
11.9.1 **Historical Bash `read -d` behavior had multibyte edge cases** _(impact: low; consensus: low)_ - Some Bash 5.0 through pre-release 5.3 versions had a multibyte-locale issue involving `read -d` delimiter handling that was corrected in final Bash 5.3. Treat reports involving those versions as version-specific rather than assuming current Bash shares the bug.
