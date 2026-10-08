# Bash Pitfalls Rules

## 1. Expansion, Command Construction, and Pathname Safety

### 1.1 Expansion and argument boundaries
1.1.1 **Quote expansions that should remain one argument** - Parameter expansions and command substitutions intended to produce one argument `MUST` be double-quoted.

### 1.2 Positional parameters
1.2.1 **Preserve argument boundaries with `"$@"`** - Positional parameters forwarded as separate arguments `MUST` use `"$@"`; unquoted `$@`, `$*`, and `"$*"` `MUST NOT` be used when original argument boundaries must be preserved.

### 1.3 Pathname handling
1.3.1 **Do not parse `ls` or newline-delimited output as filenames** - Arbitrary filenames `MUST NOT` be parsed from `ls` output or whitespace/newline-delimited command substitution; pathname-aware or NUL-safe mechanisms `MUST` be used instead.

### 1.4 Pathname and option safety
1.4.1 **Protect operands that begin with `-`** - Operands that may begin with `-` `MUST` be protected from option parsing with `--` where supported or an unambiguous pathname form such as an absolute path or `./` prefix.

### 1.5 Command construction
1.5.1 **Use arrays for dynamically constructed argument lists** - Dynamically constructed command arguments `MUST` be stored and expanded as an array rather than encoded as a shell-quoted command string.

### 1.6 Multi-stage evaluation
1.6.1 **Avoid `eval` for data-driven command construction** - `eval` `MUST NOT` be used merely to construct commands, assignments, or argument lists from data when direct shell constructs can represent the operation, and untrusted data `MUST NOT` be passed through `eval`.
1.6.2 **Do not accidentally execute command-substitution output** - Command substitution output `MUST NOT` be placed in command position unless executing the produced command and arguments is explicitly intended.

### 1.7 Arithmetic evaluation
1.7.1 **Treat arithmetic contexts as evaluation contexts** - Untrusted values `MUST` be validated or constrained before use in arithmetic expressions, arithmetic commands, or array subscript contexts that perform arithmetic evaluation.

### 1.8 Command construction
1.8.1 **Pass `find -exec sh -c` operands as arguments** - Pathnames supplied by `find` to `sh -c` `MUST` be passed as positional arguments and `MUST NOT` be interpolated into the shell program text.

### 1.9 Pathname transport
1.9.1 **Use NUL-safe interfaces for arbitrary pathnames** - Streams containing arbitrary pathnames `MUST` use direct pathname interfaces or NUL-delimited transport rather than newline, whitespace, or other pathname-valid delimiters.

### 1.10 Filesystem safety
1.10.1 **Create temporary resources atomically** - Temporary files or directories in shared writable locations `MUST` be created with an atomic facility such as `mktemp` and `MUST NOT` use predictable names.

### 1.11 Filesystem state
1.11.1 **Check `cd` before operating on relative paths** - A `cd` whose success determines the meaning of subsequent relative paths `MUST` be checked for success before those operations execute.

### 1.12 Filesystem mutation
1.12.1 **Fail closed on empty destructive path variables** - Variables used to construct destructive filesystem targets `MUST` be validated as present and acceptable before the destructive command executes.

## 2. File, Pipeline, and Input Safety

### 2.1 Redirection and data integrity
2.1.1 **Do not read and overwrite the same file through one pipeline** - A transformation `MUST NOT` read a file while simultaneously redirecting pipeline output to that same file; output `MUST` be written separately and committed after successful processing.
2.1.2 **Remember that output redirection truncates before command execution** - When existing target contents must survive command startup or failure, code `MUST NOT` overwrite the target directly with `>` and `MUST` write to a separate target before replacement.

### 2.2 Privilege boundaries
2.2.1 **`sudo` does not elevate shell redirections** - Redirections requiring elevated privileges `MUST` be performed within the elevated execution context and `MUST NOT` rely on `sudo command > privileged_file` to elevate the redirection.

### 2.3 Remote execution
2.3.1 **Account for local expansion in SSH command strings** - SSH command construction `MUST` account for both local and remote shell parsing, and data `MUST NOT` be interpolated into remote shell source in a form that can be reinterpreted as shell syntax.
2.3.2 **Quote remote here-document delimiters when expansion belongs remotely** - A here-document sent to a remote shell `MUST` use a locally quoted delimiter when its expansions are intended to occur on the remote host.

### 2.4 Pipelines and subshells
2.4.1 **Do not expect pipeline loop mutations to survive** - Code that requires variable mutations from a loop to persist in the parent shell `MUST NOT` place that loop in a pipeline unless it deliberately depends on configured parent-shell pipeline behavior such as `lastpipe`.

### 2.5 Pipeline status
2.5.1 **Do not assume pipeline success means every stage succeeded** - When failure of any pipeline stage matters, code `MUST` inspect or propagate all relevant stage statuses and `MUST NOT` rely solely on the pipeline's default final-command status.

### 2.6 Asynchronous execution
2.6.1 **`&` does not report the background command's final status** - When a background command's eventual success matters, its PID `MUST` be retained and its completion status `MUST` be obtained with `wait`.

### 2.7 Process substitution
2.7.1 **Do not assume process substitution contributes to command status** - When a process-substitution command's success matters, its status `MUST` be synchronized and checked explicitly rather than inferred from the surrounding command's status.

### 2.8 Exit status handling
2.8.1 **Separate declaration from status-sensitive command substitution** - When a command substitution's exit status matters, declaration or attribute-setting builtins such as `local`, `declare`, `export`, or `readonly` `MUST` be separated from the assignment.

### 2.9 Shell data model
2.9.1 **Do not store arbitrary binary data in Bash variables** - Arbitrary binary data that may contain NUL bytes `MUST NOT` be stored in Bash variables.

### 2.10 Input parsing
2.10.1 **Use `IFS= read -r` for literal text lines** - Lines whose leading/trailing whitespace and backslashes are data `MUST` be read with `IFS= read -r` or an equivalent mechanism that preserves them.

### 2.11 Input stream ownership
2.11.1 **Prevent commands inside `while read` from stealing loop input** - Commands executed inside an input-reading loop `MUST NOT` consume the loop's input stream unless that consumption is intentional; their stdin or the loop's file descriptor `MUST` be isolated when necessary.

## 3. Script Boundaries and Runtime Setup

### 3.1 Here documents
3.1.1 **Quote here-document delimiters for literal bodies** - A here-document whose body must remain literal `MUST` use a quoted delimiter.

### 3.2 Interpreter selection
3.2.1 **Declare the interpreter that matches the script language** - Scripts using Bash-specific syntax or semantics `MUST` declare Bash as their interpreter, while scripts declaring POSIX `sh` `MUST NOT` depend on Bash-specific language features.

### 3.3 Interpreter invocation
3.3.1 **Do not run a Bash script as `sh script`** - A script requiring Bash syntax or semantics `MUST NOT` be invoked with `sh`; it `MUST` be executed through Bash or its Bash shebang.

### 3.4 File descriptors
3.4.1 **Redirection order is significant** - Multiple redirections `MUST` be ordered according to Bash's left-to-right redirection semantics and `MUST NOT` be treated as commutative.

### 3.5 Output formatting
3.5.1 **Never use uncontrolled text as a `printf` format string** - Uncontrolled or data-derived text `MUST NOT` be used as the `printf` format argument; a fixed format string `MUST` be used instead.

### 3.6 Arrays
3.6.1 **Quote `"${array[@]}"` to preserve elements** - Expanding all array elements while preserving their element boundaries `MUST` use `"${array[@]}"`.

### 3.7 Arrays and parsing
3.7.1 **Do not populate arrays with unquoted command substitution** - Structured command output `MUST NOT` be loaded into an array with unquoted command substitution such as `array=( $(command) )`; a record-aware input mechanism `MUST` be used.

### 3.8 Code and data boundaries
3.8.1 **Do not `source` untrusted configuration files** - Files containing untrusted configuration data `MUST NOT` be loaded with `source` or `.` unless executing them as arbitrary shell code is explicitly intended.

### 3.9 Command lookup and sourcing
3.9.1 **Use an explicit path when sourcing a specific file** - When a specific file must be sourced, its path `MUST` be explicit rather than relying on `PATH`-dependent source lookup.

### 3.10 Startup environment
3.10.1 **Account for `BASH_ENV` in non-interactive execution** - Security-sensitive non-interactive Bash execution `MUST NOT` inherit an uncontrolled `BASH_ENV`; it `MUST` be unset or constrained before Bash startup.

### 3.11 Command resolution
3.11.1 **Control command lookup in security-sensitive scripts** - Security-sensitive Bash execution `MUST` use a trusted `PATH` or explicit executable paths and `MUST NOT` rely on an uncontrolled inherited command-search path.

### 3.12 Privilege boundaries
3.12.1 **Remember that globs are expanded before `sudo`** - Pathname expansion requiring elevated directory access `MUST` occur within the privileged execution context and `MUST NOT` rely on a glob expanded by the unprivileged invoking shell.

### 3.13 Error handling
3.13.1 **Do not treat `set -e` as complete error handling** - Scripts `MAY` use `set -e` as a guardrail but `MUST NOT` rely on it as the sole failure handling for operations whose failure must abort or alter execution.

## 4. Error Semantics and Conditional Logic

### 4.1 Error handling semantics
4.1.1 **`errexit` changes inside conditions and command substitutions** - Code that depends on `errexit` `MUST` explicitly account for contexts where Bash suppresses or clears it, including tested commands and command substitutions, rather than assuming uniform termination behavior.

### 4.2 Pipeline status
4.2.1 **Do not enable `pipefail` blindly around early-exiting consumers** - Pipelines with consumers that may intentionally terminate early `MUST` account for resulting upstream SIGPIPE statuses before treating `pipefail` failure as an operation failure.

### 4.3 Traps and error handling
4.3.1 **Do not treat `ERR` as a universal exception trap** - An `ERR` trap `MUST NOT` be used as the sole mechanism for handling failures that must always be detected.

### 4.4 Associative arrays and evaluation
4.4.1 **Treat associative-array subscripts as version-sensitive evaluation contexts** - Untrusted associative-array keys `SHOULD NOT` be placed directly into arithmetic or other repeatedly evaluated subscript expressions when supported Bash versions may exhibit repeated subscript evaluation.

### 4.5 Command substitution
4.5.1 **Command substitution removes trailing newlines** - Command substitution `MUST NOT` be used when preserving trailing newline characters from command output is required.

### 4.6 Redirection semantics
4.6.1 **Here strings append a newline** - Here strings `MUST NOT` be used when the supplied byte stream must exactly equal the source value without an appended newline.

### 4.7 Conditional expressions
4.7.1 **Quote variables used with `[ ... ]`** - Variable operands passed to `[` or `test` `MUST` be quoted where word splitting or pathname expansion could alter the intended argument structure.
4.7.2 **Prefer `[[ ... ]]` for Bash-native string tests** - Bash-specific code `SHOULD` use `[[ ... ]]` for shell-native string and pattern tests unless POSIX `sh` portability or another material constraint requires `[` or `test`.

### 4.8 Pattern matching
4.8.1 **Quote the right side of `[[ = ]]` for literal equality** - The right-hand operand of `[[ ... = ... ]]` `MUST` be quoted when literal equality rather than pattern matching is intended.

### 4.9 Regular expressions
4.9.1 **Do not quote a regex variable when regex matching is intended** - A variable containing an intended regular expression `MUST NOT` be wholly quoted on the right side of `[[ ... =~ ... ]]` when regex interpretation is required.
4.9.2 **Distinguish invalid regex from no regex match** - When a dynamically supplied regex may be invalid and that condition matters, code `MUST` distinguish `=~` status 2 from ordinary no-match status 1.
4.9.3 **Copy `BASH_REMATCH` before another regex match** - `BASH_REMATCH` values needed after a subsequent regex operation `MUST` be copied before that operation occurs.

### 4.10 Conditional expressions
4.10.1 **Use arithmetic comparison for numbers** - Values intended to be compared numerically `MUST` use arithmetic or numeric comparison operators rather than lexicographic string ordering.

## 5. Conditional, Status, Parameter, and Globbing Semantics

### 5.1 Conditional expressions
5.1.1 **Avoid `-a` and `-o` inside `test` expressions** - Compound conditions `SHOULD NOT` use `-a` or `-o` inside `[` or `test`; separate shell conditionals or `[[ ... ]]` `SHOULD` be used instead.
5.1.2 **`[ false ]` is true** - A one-argument `[` or `test` expression `MUST NOT` be used to interpret boolean-looking strings such as `false` or `0`; commands or explicit value comparisons `MUST` be used.

### 5.2 Exit status handling
5.2.1 **Test a command by running it** - Command success in a conditional `SHOULD` be tested by using the command directly as the condition rather than running it first and inspecting `$?` later.

### 5.3 Control flow
5.3.1 **`A && B || C` is not a general ternary expression** - `A && B || C` `MUST NOT` be used as an `if`/`else` substitute when `C` should execute only if `A` fails, because failure of `B` also causes `C` to run.

### 5.4 Exit status handling
5.4.1 **Capture `$?` before running anything else** - When `$?` must be inspected, it `MUST` be read or saved immediately after the command whose status is required.

### 5.5 Pipeline status
5.5.1 **Capture `PIPESTATUS` immediately** - Required `PIPESTATUS` values `MUST` be copied before executing any subsequent command or pipeline.

### 5.6 Arithmetic status
5.6.1 **Remember that `((i++))` can return failure** - `((i++))` `MUST NOT` be used where its status 1 result for an initial zero value would incorrectly trigger `errexit`, conditional chaining, or failure handling.

### 5.7 Parameter expansion
5.7.1 **Distinguish unset from empty in parameter defaults** - Parameter-default operators `MUST` use the colon form only when unset and empty values are intended to receive the same treatment; the non-colon form `MUST` be used when an explicitly empty value must be preserved.

### 5.8 Parameter expansion and patterns
5.8.1 **Quote literal variables inside parameter-removal patterns** - Variable expansions used as literal prefix or suffix text in parameter-removal patterns `MUST` be quoted within the parameter expansion so their glob characters are not interpreted as pattern syntax.

### 5.9 Pattern matching
5.9.1 **Remember that `case` operands are patterns** - Expanded values used in `case` pattern positions `MUST` be quoted when their contents are intended to match literally rather than as shell patterns.

### 5.10 Filename expansion
5.10.1 **Handle unmatched globs explicitly** - Code whose correctness depends on the zero-match case for a glob `MUST` explicitly define or handle unmatched-glob behavior rather than assume the pattern disappears.
5.10.2 **Scope `nullglob` and `failglob` deliberately** - Changes to `nullglob` or `failglob` `MUST` be scoped or restored when they are not intended to affect subsequent shell code.
5.10.3 **Decide explicitly whether globs should include dotfiles** - Code whose correctness depends on including or excluding leading-dot names `MUST` explicitly account for Bash's dotfile globbing behavior.

## 6. Environment, Parsing, Filesystem Tests, and Arrays

### 6.1 Shell environment state
6.1.1 **Avoid hidden dependence on `GLOBIGNORE`** - Code requiring deterministic pathname expansion `MUST` control or neutralize inherited `GLOBIGNORE` state.

### 6.2 Parsing and shell options
6.2.1 **Enable `extglob` before parsing constructs that use it** - `extglob` `MUST` be enabled before Bash parses any function body or compound command containing extended-glob syntax.

### 6.3 Locale and pattern matching
6.3.1 **Control locale when character ranges require ASCII semantics** - Pattern ranges requiring ASCII byte-order semantics `MUST` execute under a locale that guarantees those semantics, such as `LC_ALL=C`.

### 6.4 Shell and utility boundaries
6.4.1 **Quote patterns intended for another utility** - Pattern arguments intended to be interpreted by another utility rather than by Bash `MUST` be quoted against shell pathname expansion.

### 6.5 Conditional expressions
6.5.1 **Do not pass an expanding glob to one `test -e` expression** - `[` or `test` `MUST NOT` receive an unquoted glob as a single file-test operand when that glob may expand to zero or multiple pathnames.
6.5.2 **`[[ -e pattern* ]]` does not perform pathname expansion** - `[[ -e pattern ]]` `MUST NOT` be used to determine whether a pathname glob has matches; the pattern `MUST` be expanded in a pathname-expansion context first.

### 6.6 Filesystem tests
6.6.1 **`-e` is false for a dangling symlink** - Code that must detect a symlink object even when its target is missing `MUST` use `-L` or `-h` and `MUST NOT` rely on `-e` alone.

### 6.7 Record parsing
6.7.1 **Do not treat `IFS=, read` as a CSV parser** - Data conforming to CSV quoting and escaping rules `MUST NOT` be parsed with `IFS` and `read`; a CSV-aware parser `MUST` be used.

### 6.8 Shell environment state
6.8.1 **Preserve the distinction between unset and empty `IFS`** - Temporary `IFS` changes `MUST` preserve the original set-versus-unset state when that distinction may matter, preferably by localizing the change rather than restoring only its string value.

### 6.9 Input parsing
6.9.1 **Handle an unterminated final input line when it matters** - When an unterminated final line is valid input, the read loop `MUST` process a final nonempty value even when `read` reports failure due to missing newline termination.

### 6.10 Arrays and arithmetic
6.10.1 **Indexed-array subscripts are arithmetic expressions** - Externally supplied indexed-array subscripts `MUST` be validated as acceptable arithmetic input before Bash evaluates them.

### 6.11 Arrays
6.11.1 **Bash indexed arrays are sparse** - Code `MUST NOT` infer an indexed array's highest index or density from `${#array[@]}`; actual indices `MUST` be used when index positions matter.
6.11.2 **`${array}` means element zero, not the whole array** - Code intending to operate on all array elements `MUST` use an explicit all-elements expansion such as `"${array[@]}"` and `MUST NOT` use `${array}` for that purpose.

## 7. Arrays, Arithmetic, Expansion, and Functions

### 7.1 Arrays and pathname expansion
7.1.1 **Quote array subscripts passed to `unset`** - Array-element references passed to `unset` `MUST` be quoted or otherwise protected from pathname expansion.

### 7.2 Associative arrays
7.2.1 **Do not rely on associative-array iteration order** - Code requiring deterministic associative-array order `MUST` maintain or derive an explicit ordering and `MUST NOT` rely on Bash's observed iteration order.

### 7.3 Shell data model
7.3.1 **Bash does not provide true multidimensional arrays** - Bash code `SHOULD NOT` model substantial nested or multidimensional data by treating Bash arrays as recursively nested structures.

### 7.4 Arithmetic evaluation
7.4.1 **Leading zeroes invoke octal arithmetic** - Decimal input that may contain leading zeroes `MUST` be validated or normalized before Bash arithmetic so it is not unintentionally interpreted as octal.
7.4.2 **Use `10#` carefully for signed decimal input** - Signed decimal input `MUST NOT` be converted by blindly prepending `10#`; its sign and magnitude `MUST` be handled in a form valid for Bash arithmetic.

### 7.5 Arithmetic limits
7.5.1 **Bash arithmetic overflow is not checked** - Arithmetic whose correctness depends on overflow detection or values beyond Bash's integer range `MUST` use a mechanism that provides the required range or checking and `MUST NOT` assume Bash detects overflow.
7.5.2 **Bash arithmetic is integer-only** - Calculations requiring non-integer arithmetic `MUST` use a numeric facility that supports it rather than Bash arithmetic expansion.

### 7.6 Expansion ordering
7.6.1 **Brace expansion does not use parameter expansion for its bounds** - Runtime values `MUST NOT` be used as brace-expansion bounds such as `{1..$n}`; dynamic ranges `MUST` use a runtime construct such as arithmetic iteration.

### 7.7 Expansion scale
7.7.1 **Avoid huge brace expansions** - Large dynamic or potentially large ranges `SHOULD NOT` be materialized with brace expansion when an iterative or streaming mechanism can avoid generating the entire word list at once.

### 7.8 Function scope
7.8.1 **Bash function locals use dynamic scope** - Bash functions `MUST NOT` assume lexical isolation of `local` variables and `MUST` account for their visibility to called functions.
7.8.2 **`declare` inside a function is local by default** - A function that intends `declare` to create or modify a global variable `MUST` request global scope explicitly rather than relying on bare `declare`.

### 7.9 Function contracts
7.9.1 **Function status defaults to the last command's status** - A function whose exit status is part of its contract `MUST` establish that status deliberately and `MUST NOT` leave it dependent on an incidental final command.

### 7.10 Positional parameters
7.10.1 **Positional parameters above 9 require braces** - Positional parameters numbered 10 or greater `MUST` be referenced with braces, such as `${10}`.

## 8. Functions, Traps, and Process Environments

### 8.1 Option parsing
8.1.1 **Reset or localize `OPTIND` before reparsing options** - Each independent or repeated `getopts` parsing pass `MUST` initialize or localize `OPTIND` so it does not inherit parser position from an earlier pass.

### 8.2 Function contracts
8.2.1 **Do not return data through shell exit status** - Shell exit status `MUST` be reserved for status information and `MUST NOT` be used to transport substantive data that cannot be represented reliably in the shell status range.

### 8.3 Traps
8.3.1 **Quote trap bodies for the intended expansion time** - Trap commands containing expansions that must occur when the trap fires `MUST` be quoted or constructed so those expansions are deferred until trap execution.

### 8.4 Traps and function execution
8.4.1 **Trap inheritance is option-dependent** - Code requiring `ERR`, `DEBUG`, or `RETURN` traps inside functions, command substitutions, or subshells `MUST` explicitly configure or install the required trap inheritance and `MUST NOT` assume it occurs automatically.

### 8.5 Signals
8.5.1 **SIGKILL and SIGSTOP cannot be trapped** - Required cleanup or integrity guarantees `MUST NOT` depend on trapping `SIGKILL` or `SIGSTOP`.
8.5.2 **Prefer signal names over numeric signal values** - Signal references `SHOULD` use symbolic signal names rather than numeric values when portability matters.

### 8.6 File descriptors
8.6.1 **Closing stderr is not equivalent to discarding it** - Code intending only to suppress stderr `MUST` redirect it to a sink such as `/dev/null` rather than close file descriptor 2, unless closed-descriptor behavior is explicitly intended.
8.6.2 **Close dynamically allocated file descriptors when finished** - Dynamically allocated persistent file descriptors `MUST` be explicitly closed when their intended lifetime ends.

### 8.7 Process execution
8.7.1 **`exec` replaces the shell on success** - Required commands or cleanup `MUST NOT` be placed after a successful `exec` with the expectation that the shell will resume execution.

### 8.8 Evaluation order
8.8.1 **Temporary environment assignments do not affect same-command shell expansion** - When a new variable value must affect shell expansions used in a command's arguments or redirections, the assignment `MUST` occur before that command rather than only as its temporary environment prefix.

### 8.9 Execution environments
8.9.1 **Use subshell grouping when temporary state should not escape** - Shell-state changes that should not escape an operation `SHOULD` be isolated in a subshell when doing so preserves the required behavior.

### 8.10 Pipelines and shell options
8.10.1 **Do not depend accidentally on `lastpipe`** - Code requiring the final pipeline component to mutate the parent shell `MUST NOT` depend on `lastpipe` unless that option and its required job-control conditions are explicitly controlled.

### 8.11 Asynchronous execution
8.11.1 **Save `$!` immediately for each asynchronous job** - A background process identifier needed later `MUST` be copied from `$!` before another asynchronous process or applicable process substitution is started.

## 9. Script Execution, Utilities, and Environment

### 9.1 Asynchronous execution
9.1.1 **Background commands may receive `/dev/null` as stdin** - A background command that requires meaningful standard input `MUST` receive an explicit input source rather than relying on inherited stdin.

### 9.2 Script location
9.2.1 **Use `BASH_SOURCE` rather than `$0` for the currently sourced Bash file** - Bash code locating the file that defines the current sourced code or function `MUST` use `BASH_SOURCE` rather than `$0`.

### 9.3 Process identity
9.3.1 **Use `BASHPID` when the current Bash process ID is required** - Code requiring the PID of the current Bash process `MUST` use `BASHPID` rather than assuming `$$` changes with every Bash subshell context.

### 9.4 Sourcing and scope
9.4.1 **Remember that sourcing mutates the current shell** - Code `MUST NOT` assume `source` or `.` isolates shell state; when sourced code's state changes must not escape, it `MUST` be executed in an isolated shell environment.

### 9.5 Interpreter selection
9.5.1 **Keep the shebang at the beginning of the file** - An executable shell script's shebang `MUST` be the first line of the file with no preceding blank lines or comments.

### 9.6 Source representation
9.6.1 **Keep shell scripts free of CRLF line endings** - Shell scripts intended for Unix execution `MUST` use LF rather than CRLF line endings.

### 9.7 Interpreter portability
9.7.1 **Do not assume portable multi-argument shebang parsing** - Shebangs intended to be portable across Unix-like systems `SHOULD NOT` depend on arbitrary multi-argument interpreter parsing unless all target platforms explicitly support the chosen mechanism.

### 9.8 Parsing and reusable commands
9.8.1 **Prefer functions to aliases in scripts** - Non-interactive Bash scripts `SHOULD` use functions rather than aliases for reusable or parameterized behavior unless alias-specific parse-time semantics are explicitly required.

### 9.9 Command lookup
9.9.1 **Use `command -v` for shell-aware command discovery** - Shell-aware command discovery `SHOULD` use `command -v` rather than relying on the external `which` utility.

### 9.10 Output formatting
9.10.1 **Prefer `printf` to `echo` for predictable output** - Code requiring predictable or portable literal output `SHOULD` use `printf` with a fixed format rather than `echo`.

### 9.11 Utility integration
9.11.1 **Quote `tr` ranges and decide their locale semantics** - `tr` operands containing ranges or character classes `MUST` be quoted against shell expansion, and code requiring specific ASCII range semantics `MUST` control the applicable locale.

### 9.12 Process discovery
9.12.1 **Do not identify processes with `ps | grep`** - Code that requires reliable process identification `MUST NOT` use `ps | grep`; it `MUST` track known PIDs or use a purpose-built process lookup mechanism.

### 9.13 Environment-dependent directory resolution
9.13.1 **Do not export `CDPATH` casually** - Scripts requiring deterministic relative `cd` resolution `MUST` control or neutralize `CDPATH` rather than relying on an uncontrolled inherited value.

## 10. Shell State, Syntax, and Compatibility

### 10.1 Shell option state
10.1.1 **Treat shell option changes as shared state** - Changes made with `set` or `shopt` `MUST` be scoped or restored when they are not intended to affect later code in the same shell.

### 10.2 Regular expressions
10.2.1 **Bash `=~` uses extended regular expressions, not PCRE** - Regular expressions used with Bash `=~` `MUST` conform to Bash's supported extended regular-expression semantics and `MUST NOT` rely on PCRE-specific syntax or behavior.

### 10.3 Error handling
10.3.1 **Do not assume `set -u` is universally beneficial strictness** - `set -u` `SHOULD` be enabled only when the script's unset-value semantics and supported Bash versions are compatible with it, and it `MUST NOT` be treated as universally safe strict-mode behavior.

### 10.4 File output safety
10.4.1 **Treat `noclobber` as a guardrail, not a complete write strategy** - Code requiring atomic or failure-safe file replacement `MUST NOT` rely solely on `noclobber`; it `MUST` use a write strategy that provides the required integrity guarantees.

### 10.5 Parallel execution
10.5.1 **Parallel `xargs` jobs can interleave output** - Parallel `xargs` jobs writing logical records to a shared output stream `MUST` buffer, serialize, or otherwise coordinate publication when record boundaries must remain intact.

### 10.6 Variable attributes and evaluation
10.6.1 **`declare -i` turns assignments into arithmetic evaluation** - Untrusted text `MUST` be validated before assignment to `declare -i` variables because those assignments are evaluated as arithmetic expressions.

### 10.7 Indirection
10.7.1 **Validate names before using namerefs for indirect assignment** - Nameref target names derived from untrusted or externally supplied data `MUST` be validated and constrained to the variables the operation is permitted to reference.

### 10.8 Command substitution syntax
10.8.1 **Prefer `$(...)` to backtick command substitution** - New Bash code `SHOULD` use `$(...)` rather than backticks for command substitution.

### 10.9 Tilde expansion
10.9.1 **A quoted tilde does not perform tilde expansion** - A quoted home-directory pathname `MUST` use an expansion such as `"$HOME/..."` rather than `"~/..."` when home-directory expansion is required.

### 10.10 Assignment and portability
10.10.1 **Separate assignment and export when tilde portability matters** - Portable shell code `SHOULD` separate tilde-containing assignment from `export` rather than relying on shell-specific tilde-expansion behavior inside declaration builtins.

### 10.11 Here documents
10.11.1 **`<<-` strips tabs, not arbitrary indentation** - Here-documents relying on `<<-` indentation stripping `MUST` use leading tab characters for the indentation to be stripped and `MUST NOT` rely on spaces being removed.

### 10.12 Lexical syntax
10.12.1 **Nothing may follow a line-continuation backslash** - A backslash used for shell line continuation `MUST` be the final character before the newline.
10.12.2 **Comments and backslash continuation interact poorly** - Comment-only lines `MUST NOT` be inserted within a backslash-continued command when subsequent lines are intended to remain part of that command.

## 11. Command Behavior, Portability, and Aliases

### 11.1 Command resolution
11.1.1 **`time` may be a shell reserved word rather than the external utility** - Code requiring a specific external `time` implementation or its options `MUST` invoke that implementation explicitly rather than assume `time` resolves to the external utility.

### 11.2 Legacy utility idioms
11.2.1 **Prefer Bash arithmetic and parameter expansion to `expr`** - Bash-specific code `SHOULD` use native arithmetic and parameter expansion instead of `expr` for ordinary arithmetic and string operations supported directly by Bash.

### 11.3 Function execution boundaries
11.3.1 **Shell functions are not ordinary external executables** - Code crossing into `sudo`, another shell, or another process `MUST NOT` assume caller-defined shell functions are available there unless their definition or export is explicitly arranged.

### 11.4 Parameter expansion syntax
11.4.1 **Separate a negative substring offset from `:`** - Negative substring offsets in Bash parameter expansion `MUST` be syntactically separated from `:` so they cannot be parsed as the `:-` default-value operator.

### 11.5 Arrays
11.5.1 **Negative indexed-array subscripts count from the end** - Code for which negative array indices are invalid `MUST` reject them explicitly and `MUST NOT` assume Bash treats them as invalid subscripts.
11.5.2 **Commas are not separators in ordinary Bash array assignments** - Bash array elements `MUST` be separated by shell word syntax and `MUST NOT` use commas as element separators unless the comma is intentionally part of an element.

### 11.6 Portability
11.6.1 **`$(<file)` is Bash-specific shorthand** - Code required to run under portable POSIX `sh` `MUST NOT` use Bash-specific `$(<file)` command-substitution shorthand.
11.6.2 **Process substitution is not portable POSIX `sh`** - Code required to run under portable POSIX `sh` `MUST NOT` use `<(...)` or `>(...)` process substitution.
11.6.3 **Here strings are not portable POSIX `sh`** - Code required to run under portable POSIX `sh` `MUST NOT` use `<<<` here strings.
11.6.4 **Prefer `.` to `source` only when POSIX portability is required** - Shell code required to be POSIX-portable `MUST` use `.` rather than Bash-specific `source`; Bash-only code `MAY` use either.

### 11.7 Aliases
11.7.1 **Do not expect an alias to accept function-style parameters** - Reusable shell behavior requiring positional parameters `MUST` be implemented as a function or executable command rather than an alias.

### 11.8 Aliases and parsing
11.8.1 **Alias definitions may not take effect inside the same parsed compound command** - Code `MUST NOT` rely on an alias defined inside a compound construct becoming available to later text within that same already-parsed construct.

### 11.9 Version-specific input behavior
11.9.1 **Historical Bash `read -d` behavior had multibyte edge cases** - Workarounds for the historical multibyte `read -d` delimiter bug `SHOULD` be conditioned on affected Bash versions and `SHOULD NOT` be applied unconditionally to Bash 5.3 or later.

