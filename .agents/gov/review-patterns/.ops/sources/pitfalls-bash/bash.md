#### User said:

Research as comprehensively as practical for Bash-specific pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms, especially cases where experienced shell developers recommend "do this instead of that."

The goal is to identify as many distinct, materially useful Bash practices as possible, not just the most popular or obvious examples.

Research across the full Bash language, shell expansion and evaluation behavior, builtins, process and pipeline semantics, interaction with Unix/POSIX utilities, scripting practices, and environment behavior that materially affect Bash programs.

Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.

Actively look for unexpected or less obvious classes of issues that may not fit common Bash best-practice lists.

For every finding, provide exactly:

Name:
Category:
Impact:
Consensus:
Description:
Why:
Source URL:

Use the fields as follows:

- Name - concise name for the pattern, pitfall, or recommendation.
- Category - a technical category derived from the findings during research. Do not force findings into a predefined category set.
- Impact - High, Medium, or Low based on how materially the issue can affect correctness, reliability, maintainability, security, portability, data integrity, or development outcomes.
- Consensus - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced Bash and shell practitioners.
- Description - explain the issue or recommendation, including the problematic approach and preferred alternative where applicable.
- Why - explain why the preferred approach matters and what problems it prevents or improves.
- Source URL - provide the strongest relevant source supporting the finding.

Organize the final results into:

1. High Impact
2. Medium Impact
3. Low Impact

Within each impact level, order findings from highest to lowest consensus.

Research broadly across authoritative and high-quality sources. Prefer primary and authoritative sources when they adequately support a finding, while also using high-quality practitioner sources where they provide material guidance not covered by primary documentation.

Potential source types include:

- GNU Bash documentation and manual
- POSIX shell specifications where relevant to Bash behavior or portability
- Bash source, release notes, and maintainer documentation
- ShellCheck documentation and rationale
- guidance from Bash, shell, and Unix experts
- established engineering documentation
- technically rigorous articles and discussions

Do not treat popularity, repetition, lint warnings, or search ranking alone as evidence of correctness or consensus. Investigate the underlying technical reason for each recommendation.

Evaluate Impact and Consensus independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on guidance specific to Bash, including language semantics, expansion behavior, quoting, command execution, pipelines, subshells, processes, exit status handling, filesystem interaction, and broadly applicable shell scripting practices. Include POSIX portability concerns when they materially affect how Bash code should be written, but distinguish portability recommendations from Bash-specific correctness recommendations.

Do not fill the results with generic programming or Unix advice unless Bash introduces a distinct consideration.

Do not stop after finding a conventional "Bash best practices" or "strict mode" list. Treat commonly repeated shell advice as a starting point to investigate, not as automatically correct guidance.

Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.

-----
#### Assistant said:

I’ll treat common advice like quoting, `set -e`, pipelines, arrays, `read`, globbing, traps, and portability as hypotheses to verify, then expand from the source material into less obvious failure modes. I’ll merge duplicate recommendations and keep Impact separate from Consensus.

-----
#### Assistant said:

The first pass already turns up several cases where conventional advice needs qualification: `set -e`, global `pipefail`, and even some associative-array expressions have context/version-dependent behavior rather than a simple universal rule. I’m treating those as separate findings only where the underlying failure mode is genuinely distinct.

-----
#### Assistant said:

A second pattern is emerging around hidden shell state: option state, `IFS`, `CDPATH`, `GLOBIGNORE`, locale, startup files, and dynamic function scope can change otherwise-correct code without changing the code itself. These are being kept where the effect is concrete enough to justify a distinct finding.

-----
#### Assistant said:

The categories below were derived from the findings after discovery rather than used to constrain the search.

## 1. High Impact

Name: Quote expansions that should remain one argument  
Category: Expansion and argument boundaries  
Impact: High  
Consensus: High  
Description: Use `"$var"` and `"$(command)"` when the expansion is intended to produce one argument. Unquoted parameter and command expansions are subject to word splitting and pathname expansion.  
Why: Otherwise spaces, tabs, wildcard characters, and empty values can silently change the number or meaning of arguments passed to a command.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Word-Splitting.html citeturn863082search36

Name: Preserve argument boundaries with `"$@"`  
Category: Positional parameters  
Impact: High  
Consensus: High  
Description: Forward arguments with `"$@"`, not unquoted `$@`, `$*`, or `"$*"`. Inside double quotes, `"$@"` expands each positional parameter as a separate word.  
Why: It preserves empty arguments and arguments containing whitespace, glob characters, or other special characters exactly as received.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Special-Parameters.html citeturn729676search12

Name: Do not parse `ls` or newline-delimited output as filenames  
Category: Pathname handling  
Impact: High  
Consensus: High  
Description: Do not use constructs such as `for f in $(ls ...)` or otherwise assume filenames are separated by whitespace or newlines. Use shell globs, `find -exec`, or NUL-delimited interfaces.  
Why: Unix filenames may contain spaces, tabs, newlines, wildcard characters, and other text that destroys delimiter-based parsing.  
Source URL: https://www.gnu.org/software/findutils/manual/html_node/find_html/Safe-File-Name-Handling.html citeturn616867search31

Name: Protect operands that begin with `-`  
Category: Pathname and option safety  
Impact: High  
Consensus: High  
Description: When filenames or other data may begin with a hyphen, terminate options with `--` where supported, as in `rm -- "$file"`, or make pathnames unambiguous with forms such as `./*`.  
Why: Without this separation, user-controlled or unexpected filenames can be interpreted as command-line options, including destructive ones.  
Source URL: https://www.shellcheck.net/wiki/SC2035 citeturn698259search15

Name: Use arrays for dynamically constructed argument lists  
Category: Command construction  
Impact: High  
Consensus: High  
Description: Store a command's arguments in an array and invoke it with `"${args[@]}"`. Do not build a single string containing shell quotes or escaped spaces and expect those characters to become shell syntax when the variable expands.  
Why: Quotes stored inside variables are ordinary characters, not quoting syntax. String-built commands commonly break argument boundaries and encourage unsafe reparsing.  
Source URL: https://www.shellcheck.net/wiki/SC2089 citeturn729676search11

Name: Avoid `eval` for data-driven command construction  
Category: Multi-stage evaluation  
Impact: High  
Consensus: High  
Description: Do not pass data, especially untrusted data, through `eval` merely to build commands, indirect assignments, or argument lists. Prefer arrays, associative arrays, namerefs where safe, or explicit dispatch.  
Why: `eval` performs another shell parse, turning characters that were previously data into shell syntax and creating command-injection opportunities.  
Source URL: https://mywiki.wooledge.org/BashFAQ/048 citeturn978950search2

Name: Do not accidentally execute command-substitution output  
Category: Multi-stage evaluation  
Impact: High  
Consensus: High  
Description: `$(command)` produces text. Placing that expansion where Bash expects a command, such as `$(get_command)`, causes the resulting text to be split and used as a command and arguments. Do this only when execution is explicitly intended.  
Why: Output that was intended merely as data can unexpectedly become executable input.  
Source URL: https://www.shellcheck.net/wiki/SC2091 citeturn332716search33

Name: Treat arithmetic contexts as evaluation contexts  
Category: Arithmetic evaluation  
Impact: High  
Consensus: High  
Description: Validate untrusted values before inserting them into `$((...))`, `((...))`, array subscripts, or other arithmetic contexts. Bash arithmetic performs recursive variable evaluation and can encounter command substitutions through crafted expressions.  
Why: Arithmetic syntax is not merely numeric conversion. Treating arbitrary strings as numbers can create command injection and unintended variable access.  
Source URL: https://www.vidarholen.net/contents/blog/?p=716 citeturn112369search0

Name: Pass `find -exec sh -c` operands as arguments  
Category: Command construction  
Impact: High  
Consensus: High  
Description: Do not interpolate `{}` directly into the shell program supplied to `find -exec sh -c`. Pass filenames after the script and access them through positional parameters, such as `sh -c 'for f do ...; done' sh {} +`.  
Why: A pathname inserted into shell source can contain shell metacharacters and become executable code. Passing it as an argument preserves the data boundary.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn532306view3

Name: Use NUL-safe interfaces for arbitrary pathnames  
Category: Pathname transport  
Impact: High  
Consensus: High  
Description: For pathname streams, prefer `find -exec ... {} +` or NUL-delimited pairs such as `find -print0` with `xargs -0` or `read -d ''`.  
Why: NUL is the one byte forbidden in Unix pathnames, making it the reliable delimiter when arbitrary filenames must cross a stream boundary.  
Source URL: https://www.gnu.org/software/findutils/manual/html_node/find_html/Safe-File-Name-Handling.html citeturn616867search31

Name: Create temporary resources atomically  
Category: Filesystem safety  
Impact: High  
Consensus: High  
Description: Do not create predictable temporary paths such as `/tmp/script.$$`. Use `mktemp`, preferably a private temporary directory where multiple related files are needed, and arrange cleanup.  
Why: Predictable names in shared writable directories create races, collisions, symlink attacks, and accidental interaction between concurrent instances.  
Source URL: https://mywiki.wooledge.org/BashFAQ/062 citeturn603714search2

Name: Check `cd` before operating on relative paths  
Category: Filesystem state  
Impact: High  
Consensus: High  
Description: Use forms such as `cd -- "$dir" || exit` or `cd -- "$dir" || return` before commands whose meaning depends on the directory change.  
Why: If `cd` fails and execution continues, later relative-path operations may modify or delete data in the wrong directory.  
Source URL: https://www.shellcheck.net/wiki/SC2164 citeturn820419search18

Name: Fail closed on empty destructive path variables  
Category: Filesystem mutation  
Impact: High  
Consensus: High  
Description: Before destructive commands, validate required paths and use defensive expansion such as `${dir:?}` where appropriate, together with quoting and option termination.  
Why: An unset or empty variable can transform a narrowly targeted command into one operating on an unintended parent directory, wildcard, or root-relative path.  
Source URL: https://www.shellcheck.net/wiki/SC2115 citeturn332716search20

Name: Do not read and overwrite the same file through one pipeline  
Category: Redirection and data integrity  
Impact: High  
Consensus: High  
Description: Avoid constructs where a command reads a file while shell redirection simultaneously opens that same file for output. Write to a separate temporary file and replace the original after success.  
Why: Output redirection can truncate the destination before the reader has consumed it.  
Source URL: https://www.shellcheck.net/wiki/SC2094 citeturn359975search1

Name: Remember that output redirection truncates before command execution  
Category: Redirection and data integrity  
Impact: High  
Consensus: High  
Description: `command > file` causes Bash to open and normally truncate `file` as part of setting up the command. For important transformations, write to another file and replace the target only after success.  
Why: The existing file can be destroyed even when the command itself cannot execute or fails immediately.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Redirections.html citeturn863082search1

Name: `sudo` does not elevate shell redirections  
Category: Privilege boundaries  
Impact: High  
Consensus: High  
Description: `sudo command > privileged-file` runs `command` through `sudo`, but the invoking shell performs `> privileged-file`. Use an appropriate privileged writer such as `sudo tee` or explicitly run the required shell operation under the elevated context.  
Why: The redirection occurs before `sudo` is involved and therefore uses the original shell's permissions.  
Source URL: https://www.shellcheck.net/wiki/SC2024 citeturn359975search1

Name: Account for local expansion in SSH command strings  
Category: Remote execution  
Impact: High  
Consensus: High  
Description: Commands sent through `ssh` commonly pass through a local shell and then a remote shell. Quote and structure them with both parsing stages in mind rather than interpolating arbitrary local values into remote shell source.  
Why: Data can be expanded by the wrong machine or become shell syntax during the second parse, producing correctness bugs or injection vulnerabilities.  
Source URL: https://www.shellcheck.net/wiki/SC2029 citeturn332716search1

Name: Quote remote here-document delimiters when expansion belongs remotely  
Category: Remote execution  
Impact: High  
Consensus: High  
Description: When feeding a script to `ssh` with a here-document, quote the local delimiter if variables and command substitutions should remain intact until the remote shell receives them.  
Why: An unquoted delimiter allows the local shell to expand the document first, potentially substituting local secrets, paths, or values into what was intended as remote code.  
Source URL: https://www.shellcheck.net/wiki/SC2087 citeturn332716search2

Name: Do not expect pipeline loop mutations to survive  
Category: Pipelines and subshells  
Impact: High  
Consensus: High  
Description: In normal Bash execution, pipeline components execute in subshell environments, so assignments inside constructs such as `producer | while read ...` generally do not modify the parent shell. Prefer redirection or carefully designed process substitution when parent-state mutation is needed.  
Why: Variables may appear to update correctly inside the loop and then unexpectedly revert after the pipeline finishes.  
Source URL: https://www.shellcheck.net/wiki/SC2031 citeturn863082search5

Name: Do not assume pipeline success means every stage succeeded  
Category: Pipeline status  
Impact: High  
Consensus: High  
Description: Without `pipefail`, a pipeline's status is normally the status of its final command. Where upstream failure matters, inspect `PIPESTATUS`, use an appropriate `pipefail` scope, or redesign the operation to propagate status explicitly.  
Why: A failed producer can be hidden by a successful consumer, allowing incomplete or corrupt results to be treated as successful.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Pipelines citeturn863082search14

Name: `&` does not report the background command's final status  
Category: Asynchronous execution  
Impact: High  
Consensus: High  
Description: Starting a command with `&` only reports successful asynchronous launch semantics. Save its PID and use `wait` when the eventual success or failure matters.  
Why: Otherwise a failed background task can be silently treated as successful by the controlling script.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Lists.html citeturn863082search15

Name: Do not assume process substitution contributes to command status  
Category: Process substitution  
Impact: High  
Consensus: High  
Description: Commands in `<(...)` or `>(...)` run asynchronously and their failures are not automatically represented by the status of the surrounding command. Arrange explicit synchronization or status reporting when their success matters.  
Why: A consumer may succeed even though a process-substitution producer failed, leaving an apparently successful operation with incomplete results.  
Source URL: https://www.shellcheck.net/wiki/SC2312 citeturn220184search4

Name: Separate declaration from status-sensitive command substitution  
Category: Exit status handling  
Impact: High  
Consensus: High  
Description: Avoid `local x=$(command)`, `export x=$(command)`, and similar constructs when `command` status matters. Declare first, then assign: `local x; x=$(command)`.  
Why: `local`, `declare`, `export`, or `readonly` can supply their own successful status and mask the command substitution's failure.  
Source URL: https://www.shellcheck.net/wiki/SC2155 citeturn863082search29

Name: Do not store arbitrary binary data in Bash variables  
Category: Shell data model  
Impact: High  
Consensus: High  
Description: Bash variables cannot represent embedded NUL bytes. Keep arbitrary binary data in files, pipes, or other byte-oriented tools rather than shell variables.  
Why: Binary data containing NUL cannot be faithfully represented, so storing it in variables necessarily loses information.  
Source URL: https://mywiki.wooledge.org/BashWeaknesses citeturn863082search26

Name: Use `IFS= read -r` for literal text lines  
Category: Input parsing  
Impact: High  
Consensus: High  
Description: For line-oriented input where whitespace and backslashes are data, use `while IFS= read -r line; do ...; done`.  
Why: Default `read` processing interprets backslashes and can trim leading or trailing characters that belong to the record.  
Source URL: https://mywiki.wooledge.org/BashFAQ/001 citeturn729676search30

Name: Prevent commands inside `while read` from stealing loop input  
Category: Input stream ownership  
Impact: High  
Consensus: High  
Description: Commands such as `ssh` that read standard input can consume data intended for the surrounding `while read` loop. Redirect their input, use options such as `ssh -n`, or dedicate another file descriptor to the loop.  
Why: The loop may terminate early or skip records in a way that depends on the nested command's input behavior.  
Source URL: https://www.shellcheck.net/wiki/SC2095 citeturn220184search22

Name: Quote here-document delimiters for literal bodies  
Category: Here documents  
Impact: High  
Consensus: High  
Description: Use a quoted delimiter such as `<<'EOF'` when the here-document body should be literal. An unquoted delimiter permits parameter expansion, command substitution, and arithmetic expansion in the body.  
Why: Templates, configuration text, generated source, and untrusted content can otherwise be unexpectedly expanded or executed by the surrounding shell.  
Source URL: https://mywiki.wooledge.org/HereDocument citeturn999147search5

Name: Declare the interpreter that matches the script language  
Category: Interpreter selection  
Impact: High  
Consensus: High  
Description: Scripts using Bash syntax should identify Bash rather than `sh`; scripts intended for POSIX `sh` should avoid Bash-specific constructs.  
Why: `/bin/sh` may be another shell, and Bash itself behaves differently in `sh` and POSIX modes. A mismatched interpreter can turn working Bash code into runtime failures or altered semantics.  
Source URL: https://www.shellcheck.net/wiki/SC2148 citeturn220184search29

Name: Do not run a Bash script as `sh script`  
Category: Interpreter invocation  
Impact: High  
Consensus: High  
Description: If a script declares Bash, execute it directly or run it with `bash script`. Calling `sh script` explicitly selects `sh` behavior instead of honoring the script's Bash interpreter declaration.  
Why: Bash-specific syntax, startup behavior, and semantic assumptions may change or fail.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html citeturn207369search1

Name: Redirection order is significant  
Category: File descriptors  
Impact: High  
Consensus: High  
Description: Redirections are processed from left to right. `command >file 2>&1` sends both streams to the file, while `command 2>&1 >file` duplicates stderr to the previous stdout before stdout is redirected.  
Why: Reversing redirections can leak output, lose diagnostics, or send sensitive information somewhere unintended.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Redirections.html citeturn863082search1

Name: Never use uncontrolled text as a `printf` format string  
Category: Output formatting  
Impact: High  
Consensus: High  
Description: Prefer `printf '%s\n' "$value"` rather than `printf "$value"`. The first argument to `printf` is a format string, not ordinary text.  
Why: Percent directives and Bash-specific format features can reinterpret supplied text, consume additional arguments, or otherwise produce unintended output.  
Source URL: https://www.shellcheck.net/wiki/SC2059 citeturn359975search1

Name: Quote `"${array[@]}"` to preserve elements  
Category: Arrays  
Impact: High  
Consensus: High  
Description: When passing every array element as arguments, use `"${array[@]}"`. Unquoted expansion permits each element to undergo additional word splitting and pathname expansion.  
Why: Element boundaries can otherwise be destroyed, especially for empty strings, whitespace-containing values, or wildcard characters.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Arrays.html citeturn504014search0

Name: Do not populate arrays with unquoted command substitution  
Category: Arrays and parsing  
Impact: High  
Consensus: High  
Description: Avoid `array=( $(command) )` when command output represents records. Use `mapfile -t array < <(command)` for line records, or an explicit delimiter-aware reader for another format.  
Why: Command substitution followed by unquoted expansion applies word splitting and pathname expansion, corrupting values that contain whitespace or glob characters.  
Source URL: https://www.shellcheck.net/wiki/SC2207 citeturn220184search13

Name: Do not `source` untrusted configuration files  
Category: Code and data boundaries  
Impact: High  
Consensus: High  
Description: `source file` and `. file` execute the file as shell code in the current shell. Use a data format and parser if the file is supposed to contain untrusted configuration data rather than executable code.  
Why: Sourcing grants the file the ability to run commands, change variables, alter traps and options, change directories, and otherwise mutate the calling shell.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html citeturn729676search6

Name: Use an explicit path when sourcing a specific file  
Category: Command lookup and sourcing  
Impact: High  
Consensus: High  
Description: When file identity matters, source `./file`, an absolute path, or a deliberately resolved path instead of relying on `source file`. Bash can search `PATH`, with additional behavior depending on mode and options.  
Why: A different file with the same name can be selected because of environment-dependent lookup behavior.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html citeturn729676search6

Name: Account for `BASH_ENV` in non-interactive execution  
Category: Startup environment  
Impact: High  
Consensus: High  
Description: When Bash executes a non-interactive shell script, `BASH_ENV` can name a file to source before the script. Security-sensitive execution should not assume a clean startup environment when hostile environment variables are possible.  
Why: Code can execute before the script's own first command.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Bash-Variables.html citeturn863082search6

Name: Control command lookup in security-sensitive scripts  
Category: Command resolution  
Impact: High  
Consensus: High  
Description: Bash searches `PATH` for external commands that contain no slash. In privileged or otherwise security-sensitive execution, use a trusted `PATH` or explicit executable paths rather than inheriting an uncontrolled search path.  
Why: A hostile earlier entry in `PATH` can cause a different executable to run under the script's authority.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Command-Search-and-Execution.html citeturn729676search9

Name: Remember that globs are expanded before `sudo`  
Category: Privilege boundaries  
Impact: High  
Consensus: High  
Description: In `sudo command /protected/*`, the invoking shell expands `*` before `sudo` runs. If the current user cannot traverse the directory, or if matching semantics differ from what the privileged command needs, perform pathname discovery inside the privileged context instead.  
Why: `sudo` elevates the command, not the shell expansion that generated its arguments.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn532306view3

Name: Do not treat `set -e` as complete error handling  
Category: Error handling  
Impact: High  
Consensus: Medium  
Description: `set -e` can be useful as a guardrail, but Bash deliberately suppresses or changes its behavior in numerous syntactic contexts. Explicitly handle failures at operations whose success is essential rather than assuming every nonzero status terminates execution.  
Why: Code that appears protected by `errexit` can continue after failures depending on where a command is called.  
Source URL: https://mywiki.wooledge.org/BashFAQ/105 citeturn863082search29

Name: `errexit` changes inside conditions and command substitutions  
Category: Error handling semantics  
Impact: High  
Consensus: Medium  
Description: Functions invoked as conditions, commands in `if`, `while`, `until`, `&&`, `||`, and other tested contexts are subject to `errexit` exceptions. Bash also normally clears `-e` in command-substitution subshells unless `inherit_errexit` or applicable POSIX behavior changes it.  
Why: Refactoring a command into a function or substitution can change whether the same internal failure terminates execution.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Command-Execution-Environment.html citeturn729676search4

Name: Do not enable `pipefail` blindly around early-exiting consumers  
Category: Pipeline status  
Impact: High  
Consensus: Medium  
Description: `pipefail` makes upstream failures visible, but consumers such as `grep -q` may intentionally exit after finding enough input, causing an upstream producer to receive SIGPIPE and return nonzero. Scope `pipefail` deliberately and understand each pipeline's expected termination behavior.  
Why: A pipeline that accomplished its intended goal can otherwise be reported as failed.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn466212view3

Name: Do not treat `ERR` as a universal exception trap  
Category: Traps and error handling  
Impact: High  
Consensus: Medium  
Description: The `ERR` trap is not invoked for several of the same contexts exempted from `errexit`, including many conditions, intermediate pipeline commands, and commands whose status is inverted.  
Why: An `ERR` trap cannot reliably serve as a language-level catch-all for every command failure.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html citeturn729676search6

Name: Treat associative-array subscripts as version-sensitive evaluation contexts  
Category: Associative arrays and evaluation  
Impact: High  
Consensus: Medium  
Description: Bash has had multiple historical behaviors involving repeated evaluation of associative-array subscripts in arithmetic and related contexts. Avoid placing untrusted keys into such expressions, and verify idioms against the Bash versions you support.  
Why: Some forms can evaluate subscript text more than once and have produced command-injection or unexpected-expansion behavior across Bash versions.  
Source URL: https://mywiki.wooledge.org/BashProgramming/05 citeturn863082search35

## 2. Medium Impact

Name: Command substitution removes trailing newlines  
Category: Command substitution  
Impact: Medium  
Consensus: High  
Description: `$(command)` removes all trailing newline characters from the captured output. Do not use ordinary command substitution when those final newlines are semantically significant.  
Why: The value stored in the variable is not byte-for-byte identical to the command's stdout.  
Source URL: https://mywiki.wooledge.org/CommandSubstitution citeturn999147search2

Name: Here strings append a newline  
Category: Redirection semantics  
Impact: Medium  
Consensus: High  
Description: `command <<< "$value"` supplies the expanded value followed by a newline. Use another input mechanism when exact stream contents are required.  
Why: A here string is not a transparent byte-preserving replacement for piping or file-descriptor input.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Redirections.html citeturn863082search1

Name: Quote variables used with `[ ... ]`  
Category: Conditional expressions  
Impact: Medium  
Consensus: High  
Description: With the traditional `test` or `[` command, quote variable operands such as `[ -n "$value" ]` and `[ "$a" = "$b" ]`.  
Why: Traditional test syntax operates on its resulting argument list, so missing or additional arguments can change parsing and meaning.  
Source URL: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html citeturn616867search0

Name: Prefer `[[ ... ]]` for Bash-native string tests  
Category: Conditional expressions  
Impact: Medium  
Consensus: High  
Description: In code explicitly targeting Bash, `[[ ... ]]` avoids word splitting and pathname expansion of ordinary operands and provides clearer pattern and regex operators. Use `[` when POSIX portability is a requirement.  
Why: It removes several argument-count and quoting hazards inherent to the external/builtin `test` grammar.  
Source URL: https://www.shellcheck.net/wiki/SC2292 citeturn820419search29

Name: Quote the right side of `[[ = ]]` for literal equality  
Category: Pattern matching  
Impact: Medium  
Consensus: High  
Description: In `[[ $value = $pattern ]]`, an unquoted right-hand operand is interpreted as a shell pattern. Write `[[ $value = "$literal" ]]` when literal equality is intended.  
Why: Characters such as `*`, `?`, and bracket expressions in data can otherwise change the comparison into pattern matching.  
Source URL: https://www.shellcheck.net/wiki/SC2053 citeturn820419search19

Name: Do not quote a regex variable when regex matching is intended  
Category: Regular expressions  
Impact: Medium  
Consensus: High  
Description: With `[[ string =~ regex ]]`, quoting the entire regex expansion makes the quoted portion literal. Use an unquoted regex variable within `[[ ]]` when its content is deliberately an extended regular expression.  
Why: Quoting rules for `=~` differ from ordinary string operands and can silently turn a regex into literal text.  
Source URL: https://www.shellcheck.net/wiki/SC2076 citeturn820419search1

Name: Distinguish invalid regex from no regex match  
Category: Regular expressions  
Impact: Medium  
Consensus: High  
Description: `[[ value =~ regex ]]` returns 0 for match, 1 for no match, and 2 when the regular expression itself is syntactically invalid.  
Why: Treating every nonzero result as an ordinary no-match can hide malformed dynamically generated patterns.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Conditional-Constructs.html citeturn820419search9

Name: Copy `BASH_REMATCH` before another regex match  
Category: Regular expressions  
Impact: Medium  
Consensus: High  
Description: `BASH_REMATCH` is maintained by Bash for `=~` results and is not a normal function-local result object. Copy captures you need before another match can overwrite them.  
Why: Helper functions or later regex operations can silently replace capture data.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Bash-Variables.html citeturn863082search6

Name: Use arithmetic comparison for numbers  
Category: Conditional expressions  
Impact: Medium  
Consensus: High  
Description: Do not use string ordering such as `[[ $x > 7 ]]` when numeric comparison is intended. Use arithmetic syntax such as `(( x > 7 ))` or numeric test operators.  
Why: String ordering is lexicographic, so numeric-looking values may compare in unexpected order.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Conditional-Constructs.html citeturn820419search9

Name: Avoid `-a` and `-o` inside `test` expressions  
Category: Conditional expressions  
Impact: Medium  
Consensus: High  
Description: Instead of complex `[ ... -a ... ]` or `[ ... -o ... ]` expressions, combine separate tests with shell `&&` and `||`, or use `[[ ... ]]` in Bash.  
Why: Multi-argument `test` expressions have historical ambiguities and are harder to reason about reliably.  
Source URL: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html citeturn616867search0

Name: `[ false ]` is true  
Category: Conditional expressions  
Impact: Medium  
Consensus: High  
Description: A one-argument `test` is true when its argument is a nonempty string. Therefore `[ false ]`, `[ 0 ]`, and similar constructs are true. Run commands such as `false` directly or perform an explicit comparison.  
Why: Shell truth is based on command exit status, while `test` has its own expression grammar.  
Source URL: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html citeturn616867search0

Name: Test a command by running it  
Category: Exit status handling  
Impact: Medium  
Consensus: High  
Description: Prefer `if command; then ...` over running a command, inspecting `$?`, and then branching. Do not place a command name inside `[ ... ]` expecting it to be executed.  
Why: Shell conditionals already consume command exit status directly, reducing opportunities to test the wrong status.  
Source URL: https://www.shellcheck.net/wiki/SC2181 citeturn220184search11

Name: `A && B || C` is not a general ternary expression  
Category: Control flow  
Impact: Medium  
Consensus: High  
Description: Do not assume `A && B || C` means exactly `if A; then B; else C; fi`. If `A` succeeds but `B` fails, `C` also runs.  
Why: The expression is a chain of exit-status operators, not a dedicated conditional expression.  
Source URL: https://www.shellcheck.net/wiki/SC2015 citeturn359975search1

Name: Capture `$?` before running anything else  
Category: Exit status handling  
Impact: Medium  
Consensus: High  
Description: If `$?` must be inspected, save it immediately after the relevant command. Prefer testing the command directly when possible.  
Why: Every subsequent command, including `echo` or an assignment command with its own status, can replace `$?`.  
Source URL: https://www.shellcheck.net/wiki/SC2320 citeturn220184search6

Name: Capture `PIPESTATUS` immediately  
Category: Pipeline status  
Impact: Medium  
Consensus: High  
Description: Bash's `PIPESTATUS` array describes the most recently executed foreground pipeline. Copy it before running another command or pipeline.  
Why: Even diagnostic or bookkeeping commands can replace the status information you intended to inspect.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Bash-Variables.html citeturn207369search4

Name: Remember that `((i++))` can return failure  
Category: Arithmetic status  
Impact: Medium  
Consensus: High  
Description: Arithmetic commands return success when the resulting expression value is nonzero. Consequently `((i++))` returns status 1 when `i` was initially zero. Use a form such as `((++i))` when that status distinction matters, or otherwise neutralize the status deliberately.  
Why: The behavior can unexpectedly trigger `errexit`, `&&`, `||`, or conditional logic.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn863082search26

Name: Distinguish unset from empty in parameter defaults  
Category: Parameter expansion  
Impact: Medium  
Consensus: High  
Description: `${var:-word}` substitutes `word` when `var` is unset or empty, while `${var-word}` substitutes only when it is unset. The same colon distinction applies to related parameter operators.  
Why: Empty and absent values often have different configuration semantics.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Shell-Parameter-Expansion.html citeturn729676search32

Name: Quote literal variables inside parameter-removal patterns  
Category: Parameter expansion and patterns  
Impact: Medium  
Consensus: High  
Description: In expressions such as `${value%$suffix}`, the suffix expansion participates as a pattern. Use the appropriate inner quoting, such as `${value%"$suffix"}`, when the expanded text should be treated literally.  
Why: Glob metacharacters contained in a supposed literal suffix or prefix can match more text than intended.  
Source URL: https://www.shellcheck.net/wiki/SC2295 citeturn729676search3

Name: Remember that `case` operands are patterns  
Category: Pattern matching  
Impact: Medium  
Consensus: High  
Description: An expanded value in a `case` pattern position remains pattern syntax unless quoted appropriately. Quote an expansion when its content should be matched literally.  
Why: User or data values containing `*`, `?`, or bracket syntax can unexpectedly broaden the match.  
Source URL: https://www.shellcheck.net/wiki/SC2254 citeturn729676search25

Name: Handle unmatched globs explicitly  
Category: Filename expansion  
Impact: Medium  
Consensus: High  
Description: By default, an unmatched Bash glob normally remains unchanged as literal text. Decide explicitly whether zero matches should produce no arguments, an error, or literal text.  
Why: Code can accidentally operate on a filename literally containing wildcard characters or pass an invalid path downstream.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Filename-Expansion.html citeturn207369search13

Name: Scope `nullglob` and `failglob` deliberately  
Category: Filename expansion  
Impact: Medium  
Consensus: High  
Description: `nullglob` removes unmatched patterns, while `failglob` turns them into an expansion error. Enable such options only where their behavior is intended, often in a subshell or tightly scoped section.  
Why: Global option changes can alter unrelated expansions far from where the option was enabled.  
Source URL: https://mywiki.wooledge.org/BashFAQ/004 citeturn863082search32

Name: Decide explicitly whether globs should include dotfiles  
Category: Filename expansion  
Impact: Medium  
Consensus: High  
Description: Ordinary `*` does not match leading-dot names. Use `dotglob` or another deliberate technique when hidden entries must be included.  
Why: Directory cleanup, copying, counting, and emptiness checks can otherwise silently omit files.  
Source URL: https://mywiki.wooledge.org/BashFAQ/004 citeturn863082search32

Name: Avoid hidden dependence on `GLOBIGNORE`  
Category: Shell environment state  
Impact: Medium  
Consensus: High  
Description: `GLOBIGNORE` changes filename expansion behavior and has interactions with dotfile matching. Scripts should set or neutralize such state deliberately when exact glob semantics matter.  
Why: Inherited or previously configured shell state can change which files a pattern selects without any visible change to the pattern itself.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Bash-Variables.html citeturn207369search4

Name: Enable `extglob` before parsing constructs that use it  
Category: Parsing and shell options  
Impact: Medium  
Consensus: High  
Description: Extended glob syntax can affect parsing. Enable `extglob` before Bash parses function bodies or compound commands containing that syntax.  
Why: Turning it on only immediately before execution may be too late because the surrounding construct has already been parsed.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Pattern-Matching.html citeturn207369search12

Name: Control locale when character ranges require ASCII semantics  
Category: Locale and pattern matching  
Impact: Medium  
Consensus: High  
Description: Bracket ranges and character classes can depend on locale. Use an appropriate locale such as `LC_ALL=C` when bytewise ASCII ordering is specifically required rather than assuming `[A-Z]` always has ASCII behavior.  
Why: Pattern results can differ between systems with different locale configuration.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Pattern-Matching.html citeturn207369search12

Name: Quote patterns intended for another utility  
Category: Shell and utility boundaries  
Impact: Medium  
Consensus: High  
Description: Quote patterns supplied to tools such as `find`, `grep`, and `tr` when those tools, rather than Bash, should interpret them.  
Why: Otherwise Bash pathname expansion may transform the pattern before the target utility receives it.  
Source URL: https://www.shellcheck.net/wiki/SC2061 citeturn729676search19

Name: Do not pass an expanding glob to one `test -e` expression  
Category: Conditional expressions  
Impact: Medium  
Consensus: High  
Description: `[ -e directory/* ]` is unsafe as an existence test because zero, one, and multiple glob matches all produce different argument structures. Use an array, loop, or deliberate glob-option technique.  
Why: Multiple matches turn one expected pathname operand into several arguments and invalidate the test expression.  
Source URL: https://www.shellcheck.net/wiki/SC2144 citeturn698259search5

Name: `[[ -e pattern* ]]` does not perform pathname expansion  
Category: Conditional expressions  
Impact: Medium  
Consensus: High  
Description: Do not expect a glob supplied as a file operand inside `[[ ]]` to enumerate matching files. Expand the pattern in a context where filename expansion actually occurs, then test the resulting paths.  
Why: `[[ ]]` suppresses ordinary pathname expansion of its operands.  
Source URL: https://www.shellcheck.net/wiki/SC2203 citeturn698259search20

Name: `-e` is false for a dangling symlink  
Category: Filesystem tests  
Impact: Medium  
Consensus: High  
Description: `[[ -e path ]]` follows the symlink target, so a broken symbolic link does not satisfy it. Use `-L` or `-h` when the existence of the link object itself is what matters.  
Why: Cleanup and link-management code can otherwise mistake an existing dangling link for an absent path.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Bash-Conditional-Expressions.html citeturn820419search0

Name: Do not treat `IFS=, read` as a CSV parser  
Category: Record parsing  
Impact: Medium  
Consensus: High  
Description: `IFS` field splitting can handle simple delimiter-separated records but does not implement CSV quoting and escaping rules, and Bash splitting has edge cases around empty fields. Use a real CSV parser for CSV.  
Why: Valid records containing quoted commas, quotes, or certain empty-field patterns can be misparsed.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn466212view2

Name: Preserve the distinction between unset and empty `IFS`  
Category: Shell environment state  
Impact: Medium  
Consensus: High  
Description: Saving `IFS` as `oldIFS=$IFS` cannot record whether it was originally unset rather than merely empty. Prefer `local IFS` in a function or a subshell when temporarily changing it.  
Why: Restoring the value alone may not restore the original shell state and semantics.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn466212view2

Name: Handle an unterminated final input line when it matters  
Category: Input parsing  
Impact: Medium  
Consensus: High  
Description: `read` can assign the final partial line and still return failure if it lacks a terminating newline. When such input is valid, use a loop condition that also processes a nonempty final value.  
Why: A naïve `while read` loop can silently discard the last record of a malformed or intentionally unterminated text file.  
Source URL: https://mywiki.wooledge.org/BashFAQ/001 citeturn729676search30

Name: Indexed-array subscripts are arithmetic expressions  
Category: Arrays and arithmetic  
Impact: Medium  
Consensus: High  
Description: `array[index]` does not require `index` to be a simple decimal literal. Indexed-array subscripts are evaluated arithmetically. Validate externally supplied index values rather than assuming they are inert strings.  
Why: Expressions can reference variables, perform arithmetic, and produce side effects or unexpected indices.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Arrays.html citeturn504014search0

Name: Bash indexed arrays are sparse  
Category: Arrays  
Impact: Medium  
Consensus: High  
Description: `${#array[@]}` is the number of assigned elements, not necessarily one more than the largest index. Iterate `"${!array[@]}"` when actual indices matter.  
Why: Deletion or explicit high indices invalidate assumptions based on dense zero-based sequences.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Arrays.html citeturn504014search0

Name: `${array}` means element zero, not the whole array  
Category: Arrays  
Impact: Medium  
Consensus: High  
Description: Referencing an indexed array without `[@]` or `[*]` behaves like a reference to subscript zero. Use `"${array[@]}"` when all elements are intended.  
Why: Code can silently operate on only the first element while appearing to reference the collection.  
Source URL: https://www.shellcheck.net/wiki/SC2128 citeturn504014search16

Name: Quote array subscripts passed to `unset`  
Category: Arrays and pathname expansion  
Impact: Medium  
Consensus: High  
Description: Use `unset 'array[index]'` or another safely quoted form rather than leaving brackets exposed to filename expansion.  
Why: Outside an arithmetic-aware context, bracket syntax can be interpreted by the shell as a pathname pattern.  
Source URL: https://www.shellcheck.net/wiki/SC2184 citeturn698259search17

Name: Do not rely on associative-array iteration order  
Category: Associative arrays  
Impact: Medium  
Consensus: High  
Description: Bash associative arrays do not provide an insertion-order contract. Maintain a separate ordered key list or sort keys when deterministic ordering is required.  
Why: Depending on observed hash iteration order makes output and behavior unstable.  
Source URL: https://mywiki.wooledge.org/BashProgramming/06 citeturn863082search33

Name: Bash does not provide true multidimensional arrays  
Category: Shell data model  
Impact: Medium  
Consensus: High  
Description: Do not model substantial nested structures by assuming Bash arrays nest like arrays or maps in general-purpose languages. Bash array elements are strings, with one-dimensional indexed and associative collections.  
Why: Attempts to emulate complex structures often lead to indirect evaluation, fragile serialization, and difficult quoting problems.  
Source URL: https://www.shellcheck.net/wiki/SC2180 citeturn504014search1

Name: Leading zeroes invoke octal arithmetic  
Category: Arithmetic evaluation  
Impact: Medium  
Consensus: High  
Description: Bash integer constants with a leading `0` are interpreted as octal. Validate decimal input or deliberately convert it before arithmetic when values such as `08` or `09` may occur.  
Why: Human-oriented numbers such as zero-padded dates can fail or yield a different value.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Shell-Arithmetic.html citeturn848903search5

Name: Use `10#` carefully for signed decimal input  
Category: Arithmetic evaluation  
Impact: Medium  
Consensus: High  
Description: Prefixing a numeric magnitude with `10#` can force decimal interpretation, but blindly constructing `10#$value` is not a complete solution for signed input. Validate the format and handle the sign separately when necessary.  
Why: A conversion idiom intended to avoid octal parsing can itself fail on valid negative representations.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn863082search26

Name: Bash arithmetic overflow is not checked  
Category: Arithmetic limits  
Impact: Medium  
Consensus: High  
Description: Bash performs fixed-width integer arithmetic using the implementation's largest integer type and does not provide general overflow detection. Use another mechanism when arithmetic range is correctness-critical.  
Why: Overflow can produce incorrect results without the kind of checked arithmetic some developers expect from higher-level environments.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Shell-Arithmetic.html citeturn848903search5

Name: Bash arithmetic is integer-only  
Category: Arithmetic limits  
Impact: Medium  
Consensus: High  
Description: Shell arithmetic does not provide native floating-point arithmetic. Use an appropriate tool such as `awk`, `bc`, or a general-purpose language when decimal arithmetic is required.  
Why: Treating decimal text as Bash arithmetic produces syntax errors or incorrect workarounds rather than real floating-point calculations.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Shell-Arithmetic.html citeturn848903search5

Name: Brace expansion does not use parameter expansion for its bounds  
Category: Expansion ordering  
Impact: Medium  
Consensus: High  
Description: Constructs such as `{1..$n}` do not create a runtime range from `$n`, because brace expansion happens before parameter expansion. Use an arithmetic loop when bounds are dynamic.  
Why: The expression can remain literal rather than producing the expected sequence.  
Source URL: https://mywiki.wooledge.org/BraceExpansion citeturn724839search17

Name: Avoid huge brace expansions  
Category: Expansion scale  
Impact: Medium  
Consensus: High  
Description: Brace expansion creates the expanded words before executing the command. For large numeric ranges, use an arithmetic loop or streaming mechanism instead.  
Why: Very large ranges can consume substantial shell memory and create enormous argument lists before useful work begins.  
Source URL: https://mywiki.wooledge.org/BraceExpansion citeturn724839search17

Name: Bash function locals use dynamic scope  
Category: Function scope  
Impact: Medium  
Consensus: High  
Description: A local variable in a Bash function is visible to functions called from that function unless they shadow it. Do not assume lexical-scope behavior from languages such as Python or JavaScript.  
Why: A helper can unintentionally read or modify a caller's local variable simply because the names coincide.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Shell-Functions.html citeturn863082search24

Name: `declare` inside a function is local by default  
Category: Function scope  
Impact: Medium  
Consensus: High  
Description: Within a function, `declare` creates a local variable unless an option such as `-g` explicitly requests global scope.  
Why: Code can appear to update a global variable while actually creating and changing only a local one.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html citeturn207369search5

Name: Function status defaults to the last command's status  
Category: Function contracts  
Impact: Medium  
Consensus: High  
Description: If a Bash function reaches its end without an explicit `return`, its status is the status of its last executed command. Use explicit status handling when the function's success contract matters.  
Why: Adding a harmless command at the end of a function can accidentally change its externally visible success or failure.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Shell-Functions.html citeturn863082search24

Name: Positional parameters above 9 require braces  
Category: Positional parameters  
Impact: Medium  
Consensus: High  
Description: Use `${10}`, `${11}`, and so on. `$10` is parsed as `$1` followed by literal `0`.  
Why: Scripts accepting many positional arguments can silently reference the wrong value.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Positional-Parameters.html citeturn863082search22

Name: Reset or localize `OPTIND` before reparsing options  
Category: Option parsing  
Impact: Medium  
Consensus: High  
Description: `getopts` uses `OPTIND` to track parser position. Functions or repeated parsing passes should deliberately initialize or localize it as appropriate.  
Why: A second parser can otherwise start at the index left by an earlier invocation and silently skip options.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html citeturn729676search6

Name: Do not return data through shell exit status  
Category: Function contracts  
Impact: Medium  
Consensus: High  
Description: Shell command and function status is a small numeric success/failure channel, conventionally 0 through 255. Return substantive data through stdout, variables, arrays, or another explicit interface.  
Why: Larger or richer values cannot be represented faithfully as exit status.  
Source URL: https://www.shellcheck.net/wiki/SC2151 citeturn332716search11

Name: Quote trap bodies for the intended expansion time  
Category: Traps  
Impact: Medium  
Consensus: High  
Description: A trap body written with double quotes can expand variables or substitutions when `trap` is installed. Single-quote the trap command when those expansions should occur when the signal or exit event happens.  
Why: Early expansion can capture stale values or execute substitutions much earlier than intended.  
Source URL: https://www.shellcheck.net/wiki/SC2064 citeturn220184search1

Name: Trap inheritance is option-dependent  
Category: Traps and function execution  
Impact: Medium  
Consensus: High  
Description: `ERR`, `DEBUG`, and `RETURN` traps are not uniformly inherited by functions, command substitutions, and subshells. Bash options such as `errtrace` and `functrace` affect inheritance.  
Why: Instrumentation or cleanup logic may disappear across execution boundaries unless inheritance semantics are explicitly understood.  
Source URL: https://www.gnu.org/s/bash/manual/bash.html citeturn729676search0

Name: SIGKILL and SIGSTOP cannot be trapped  
Category: Signals  
Impact: Medium  
Consensus: High  
Description: Do not design mandatory cleanup or data-integrity guarantees around traps for `KILL` or `STOP`; those signals cannot be caught by the shell.  
Why: Trap-based cleanup is inherently best effort and cannot cover every possible process termination.  
Source URL: https://www.shellcheck.net/wiki/SC2173 citeturn220184search2

Name: Prefer signal names over numeric signal values  
Category: Signals  
Impact: Medium  
Consensus: High  
Description: Use symbolic names such as `TERM`, `INT`, and `HUP` rather than relying on signal numbers where portability matters.  
Why: Signal-number mappings other than the most fundamental cases are not a good cross-platform interface.  
Source URL: https://www.shellcheck.net/wiki/SC2172 citeturn220184search23

Name: Closing stderr is not equivalent to discarding it  
Category: File descriptors  
Impact: Medium  
Consensus: High  
Description: `2>&-` closes file descriptor 2, while `2>/dev/null` leaves it open and directs output to a sink. Use `/dev/null` when the goal is merely to suppress output.  
Why: Programs can detect or fail when writing to a closed descriptor, changing their behavior instead of just silencing diagnostics.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn532306view3

Name: Close dynamically allocated file descriptors when finished  
Category: File descriptors  
Impact: Medium  
Consensus: High  
Description: Bash redirections such as `exec {fd}>file` allocate a descriptor and can keep it open beyond one command. Close persistent descriptors explicitly when their lifetime ends.  
Why: Descriptor leaks can keep files, pipes, or sockets open and interfere with EOF detection or resource limits.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Redirections.html citeturn863082search1

Name: `exec` replaces the shell on success  
Category: Process execution  
Impact: Medium  
Consensus: High  
Description: `exec command` does not launch a child and then resume the script. On success, the current shell process becomes the target program.  
Why: Cleanup or subsequent commands placed after a successful `exec` will never execute.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html citeturn207369search5

Name: Temporary environment assignments do not affect same-command shell expansion  
Category: Evaluation order  
Impact: Medium  
Consensus: High  
Description: In `VAR=new command "$VAR"`, the `$VAR` expansion is performed by the shell before the temporary environment assignment is made available to `command`. Separate the assignment when the new value must also affect shell-side expansion.  
Why: The command can receive the new environment variable while simultaneously receiving an argument derived from the old shell value.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Shell-Expansions.html citeturn680267search6

Name: Use subshell grouping when temporary state should not escape  
Category: Execution environments  
Impact: Medium  
Consensus: High  
Description: `( commands )` runs in a subshell environment, while `{ commands; }` normally runs in the current shell. A common idiom is `(cd dir && commands)` when directory or variable changes should be temporary.  
Why: It avoids manual restoration of shell state and reduces accidental state leakage.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Command-Execution-Environment.html citeturn863082search5

Name: Do not depend accidentally on `lastpipe`  
Category: Pipelines and shell options  
Impact: Medium  
Consensus: High  
Description: With `lastpipe` enabled and job control disabled, Bash can execute the final foreground pipeline component in the current shell rather than a subshell. Code should either deliberately depend on this configured behavior or avoid the dependency.  
Why: Variable persistence from the final pipeline stage can change solely because of shell-option state.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/The-Shopt-Builtin.html citeturn863082search7

Name: Save `$!` immediately for each asynchronous job  
Category: Asynchronous execution  
Impact: Medium  
Consensus: High  
Description: `$!` identifies the most recently started asynchronous process or applicable process substitution. Store it before launching another asynchronous operation.  
Why: Later launches replace `$!`, making it easy to wait for or signal the wrong process.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Special-Parameters.html citeturn729676search12

Name: Background commands may receive `/dev/null` as stdin  
Category: Asynchronous execution  
Impact: Medium  
Consensus: High  
Description: When job control is not active, Bash can redirect standard input for an asynchronous command without an explicit input redirection from `/dev/null`. Redirect input deliberately when a background job requires it.  
Why: A program that works interactively can encounter immediate EOF when backgrounded by a script.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Lists.html citeturn863082search15

Name: Use `BASH_SOURCE` rather than `$0` for the currently sourced Bash file  
Category: Script location  
Impact: Medium  
Consensus: High  
Description: When Bash code needs the pathname associated with a sourced file or function stack, use the `BASH_SOURCE` array. `$0` identifies the shell or top-level script invocation and does not change simply because another file was sourced.  
Why: `dirname "$0"` commonly locates the caller rather than the library file itself.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Bash-Variables.html citeturn863082search6

Name: Use `BASHPID` when the current Bash process ID is required  
Category: Process identity  
Impact: Medium  
Consensus: High  
Description: `$$` identifies the invoking shell process and can remain unchanged in subshell constructs. `BASHPID` identifies the current Bash process and therefore differs in relevant subshell situations.  
Why: Code using process IDs for temporary names, logging, or process coordination can otherwise identify the wrong shell instance.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Bash-Variables.html citeturn729676search7

Name: Remember that sourcing mutates the current shell  
Category: Sourcing and scope  
Impact: Medium  
Consensus: High  
Description: `source` and `.` execute commands in the current shell rather than in an isolated child. Use a subshell when you intentionally want the sourced code's variable, directory, option, or trap changes isolated.  
Why: A sourced helper can change global execution state far beyond its apparent return values.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html citeturn729676search6

Name: Keep the shebang at the beginning of the file  
Category: Interpreter selection  
Impact: Medium  
Consensus: High  
Description: The interpreter line must be the file's first line in the required `#!` position. Do not place comments or blank lines before it.  
Why: Otherwise direct execution may not invoke the intended interpreter.  
Source URL: https://www.shellcheck.net/wiki/SC1128 citeturn698259search27

Name: Keep shell scripts free of CRLF line endings  
Category: Source representation  
Impact: Medium  
Consensus: High  
Description: Shell scripts intended for Unix execution should use LF line endings. A carriage return from CRLF can become part of tokens, delimiters, or the interpreter pathname.  
Why: Scripts can fail with misleading errors such as an apparently nonexistent `/bin/bash\r` interpreter.  
Source URL: https://www.shellcheck.net/wiki/SC1017 citeturn698259search0

Name: Do not assume portable multi-argument shebang parsing  
Category: Interpreter portability  
Impact: Medium  
Consensus: High  
Description: Kernel shebang handling historically does not provide a portable way to express arbitrary multiple interpreter arguments. Keep interpreter invocation simple unless the deployment platforms and features such as `env -S` are explicitly controlled.  
Why: The same shebang text can be tokenized differently or rejected across systems.  
Source URL: https://www.shellcheck.net/wiki/SC2096 citeturn698259search40

Name: Prefer functions to aliases in scripts  
Category: Parsing and reusable commands  
Impact: Medium  
Consensus: High  
Description: Aliases are primarily an interactive convenience. Their expansion is parse-time, is normally disabled in non-interactive shells unless configured otherwise, and does not behave like a parameterized function.  
Why: Script behavior can depend on parse boundaries and shell option state in non-obvious ways.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Aliases.html citeturn243606search0

Name: Use `command -v` for shell-aware command discovery  
Category: Command lookup  
Impact: Medium  
Consensus: High  
Description: Prefer `command -v name` when a script needs to determine what the shell would resolve for a command name. Avoid depending on the nonstandard external `which` utility.  
Why: `command -v` participates in shell command-resolution semantics and can account for shell constructs that an external path scanner cannot reliably represent.  
Source URL: https://pubs.opengroup.org/onlinepubs/9799919799.2024edition/utilities/command.html citeturn616867search30

Name: Prefer `printf` to `echo` for predictable output  
Category: Output formatting  
Impact: Medium  
Consensus: High  
Description: Use `printf '%s\n' "$value"` when exact portable behavior matters. `echo` has historically variable handling of `-n`, backslashes, and implementation-specific options.  
Why: Data beginning with option-like text or containing backslashes may not be emitted literally across environments.  
Source URL: https://pubs.opengroup.org/onlinepubs/9699919799.2016edition/utilities/echo.html citeturn616867search1

Name: Quote `tr` ranges and decide their locale semantics  
Category: Utility integration  
Impact: Medium  
Consensus: High  
Description: Do not write unquoted shell-looking forms such as `tr [A-Z] [a-z]`. Quote the operands, and use character classes or a controlled locale according to the intended character semantics.  
Why: Shell globbing can alter unquoted bracket expressions, while locale can change the character set or ordering assumed by ranges.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn466212view1

Name: Do not identify processes with `ps | grep`  
Category: Process discovery  
Impact: Medium  
Consensus: High  
Description: Prefer tracking the PID of the process you launched, or use a purpose-built interface such as `pgrep` when process-name lookup is genuinely required.  
Why: `ps | grep` can match itself, unrelated commands, truncated or transformed command lines, and inherently races against process creation and exit.  
Source URL: https://www.shellcheck.net/wiki/SC2009 citeturn359975search1

Name: Do not export `CDPATH` casually  
Category: Environment-dependent directory resolution  
Impact: Medium  
Consensus: High  
Description: `CDPATH` changes how Bash resolves relative operands to `cd` and can cause successful `cd` operations to print the selected directory. Scripts should avoid inheriting or exporting a surprising `CDPATH` when deterministic relative-directory behavior matters.  
Why: The same `cd relative/path` can select a different location because of ambient environment state.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Bash-Variables.html citeturn207369search4

Name: Treat shell option changes as shared state  
Category: Shell option state  
Impact: Medium  
Consensus: High  
Description: Options changed with `set` or `shopt` can affect later code in the same shell, including callers of sourced files and functions. Use subshells or explicit save-and-restore logic when an option is intended to be local to one operation.  
Why: A helper that changes globbing, error, tracing, or expansion options can alter unrelated downstream behavior.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/The-Shopt-Builtin.html citeturn863082search7

Name: Bash `=~` uses extended regular expressions, not PCRE  
Category: Regular expressions  
Impact: Medium  
Consensus: High  
Description: Patterns used by `[[ value =~ regex ]]` follow Bash's POSIX extended regular-expression interface. Do not assume constructs from PCRE, Perl, or other regex dialects have the same meaning.  
Why: A regex can be syntactically valid yet mean something different from what the author intended.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Conditional-Constructs.html citeturn820419search9

Name: Do not assume `set -u` is universally beneficial strictness  
Category: Error handling  
Impact: Medium  
Consensus: Medium  
Description: `set -u` catches some accidental references to unset variables, but unset values are also a legitimate part of shell semantics and historical Bash versions have additional array-related edge cases. Use it deliberately rather than assuming every script should enable it.  
Why: Code can become brittle around optional parameters, empty arrays, and intentionally absent variables without necessarily gaining proportional correctness.  
Source URL: https://mywiki.wooledge.org/BashFAQ/112 citeturn863082search27

Name: Treat `noclobber` as a guardrail, not a complete write strategy  
Category: File output safety  
Impact: Medium  
Consensus: Medium  
Description: `set -C` or `set -o noclobber` prevents ordinary `>` redirection from replacing an existing regular file, but `>|` overrides it and the option does not replace explicit transactional or atomic-write design.  
Why: It can prevent some accidental overwrites while leaving other data-integrity concerns untouched.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Redirections.html citeturn863082search1

Name: Parallel `xargs` jobs can interleave output  
Category: Parallel execution  
Impact: Medium  
Consensus: Medium  
Description: When using `xargs -P`, do not assume multiple workers can safely write arbitrary multi-part records to a shared stdout stream without coordination. Buffer per-job output or serialize publication when record integrity matters.  
Why: Concurrent processes can intermix output and produce a stream that no longer corresponds to complete logical records.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn466212view3

Name: `declare -i` turns assignments into arithmetic evaluation  
Category: Variable attributes and evaluation  
Impact: Medium  
Consensus: Medium  
Description: Integer-attributed variables cause assigned values to be evaluated as arithmetic expressions. Avoid feeding uncontrolled strings into `declare -i` variables, and prefer explicit arithmetic where hidden evaluation would be surprising.  
Why: A seemingly ordinary assignment becomes another expression-evaluation boundary and can inherit arithmetic injection hazards.  
Source URL: https://mywiki.wooledge.org/BashProgramming/05 citeturn863082search35

Name: Validate names before using namerefs for indirect assignment  
Category: Indirection  
Impact: Medium  
Consensus: Medium  
Description: `declare -n` allows one variable to refer to another by name. When the target name originates outside trusted code, validate it and constrain which variables may be referenced.  
Why: Indirection can otherwise turn data into authority to inspect or modify arbitrary shell variables.  
Source URL: https://mywiki.wooledge.org/BashProgramming/05 citeturn863082search35

## 3. Low Impact

Name: Prefer `$(...)` to backtick command substitution  
Category: Command substitution syntax  
Impact: Low  
Consensus: High  
Description: Both forms are supported, but prefer `$(command)` for new code. It nests directly and has clearer quoting and escaping rules than legacy backticks.  
Why: Nested substitutions and commands containing backslashes are easier to read and maintain correctly.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Major-Differences-From-The-Bourne-Shell.html citeturn863082search0

Name: A quoted tilde does not perform tilde expansion  
Category: Tilde expansion  
Impact: Low  
Consensus: High  
Description: `"~/file"` contains a literal tilde. Use `"$HOME/file"` when a home-directory path must remain quoted.  
Why: Quoting the tilde suppresses the special expansion the author was relying on.  
Source URL: https://www.shellcheck.net/wiki/SC2088 citeturn332716search30

Name: Separate assignment and export when tilde portability matters  
Category: Assignment and portability  
Impact: Low  
Consensus: High  
Description: Shells differ historically in whether a tilde in forms such as `export var=~/dir` receives assignment-context treatment. `var=$HOME/dir; export var` is unambiguous.  
Why: The explicit two-step form avoids depending on shell-specific parsing of declaration builtins.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn466212view1

Name: `<<-` strips tabs, not arbitrary indentation  
Category: Here documents  
Impact: Low  
Consensus: High  
Description: The `<<-` here-document form strips leading tab characters from the body and delimiter. It does not generally strip spaces used for indentation.  
Why: A visually indented closing delimiter made with spaces may not terminate the here-document as expected.  
Source URL: https://www.shellcheck.net/wiki/SC1040 citeturn698259search19

Name: Nothing may follow a line-continuation backslash  
Category: Lexical syntax  
Impact: Low  
Consensus: High  
Description: A backslash continues a physical line only when it immediately precedes the newline. Trailing spaces after the backslash prevent that interpretation.  
Why: Invisible whitespace can change one logical command into multiple commands or produce confusing syntax errors.  
Source URL: https://www.shellcheck.net/wiki/SC1101 citeturn698259search1

Name: Comments and backslash continuation interact poorly  
Category: Lexical syntax  
Impact: Low  
Consensus: High  
Description: Do not insert a comment as though it were an invisible item in the middle of a backslash-continued command. Structure the command differently or move the explanatory comment.  
Why: Shell lexical rules can cause the continuation or subsequent arguments to be parsed differently from the visual layout.  
Source URL: https://www.shellcheck.net/wiki/SC1143 citeturn698259search2

Name: `time` may be a shell reserved word rather than the external utility  
Category: Command resolution  
Impact: Low  
Consensus: High  
Description: Bash has a `time` reserved word that can time pipelines and has shell-specific formatting behavior. If a script specifically requires an external `time` implementation and its options, invoke that implementation deliberately.  
Why: Assuming every `time` invocation refers to the same external executable can produce option and output-format differences.  
Source URL: https://www.shellcheck.net/wiki/SC2023 citeturn359975search1

Name: Prefer Bash arithmetic and parameter expansion to `expr`  
Category: Legacy utility idioms  
Impact: Low  
Consensus: High  
Description: In Bash-specific code, prefer `$((...))`, `${#value}`, and appropriate shell constructs over spawning or invoking `expr` for ordinary arithmetic and string-length work.  
Why: Native syntax is clearer, avoids `expr`'s operator and quoting peculiarities, and normally avoids an external process.  
Source URL: https://www.shellcheck.net/wiki/SC2003 citeturn820419search7

Name: Shell functions are not ordinary external executables  
Category: Function execution boundaries  
Impact: Low  
Consensus: High  
Description: A Bash function exists in shell state and cannot simply be invoked by an unrelated process as though it were a file in `PATH`. Use an executable script when behavior must naturally cross process or privilege boundaries.  
Why: Commands such as `sudo`, `env`, or another shell do not automatically share the caller's function table.  
Source URL: https://www.shellcheck.net/wiki/SC2033 citeturn359975search1

Name: Separate a negative substring offset from `:`  
Category: Parameter expansion syntax  
Impact: Low  
Consensus: High  
Description: Write forms such as `${value: -1}` when using a negative substring offset. Without separation, `:-` is parsed as the default-value parameter operator.  
Why: Two valid parameter-expansion syntaxes overlap lexically and can produce a completely different operation.  
Source URL: https://www.gnu.org/s/bash/manual/html_node/Shell-Parameter-Expansion.html citeturn729676search32

Name: Negative indexed-array subscripts count from the end  
Category: Arrays  
Impact: Low  
Consensus: High  
Description: Bash accepts negative indexed-array subscripts in relevant contexts, interpreting them relative to one greater than the maximum assigned index. Do not assume a negative subscript is automatically an error.  
Why: Code ported from languages with different negative-index semantics may access an unexpected element.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Arrays.html citeturn504014search0

Name: Commas are not separators in ordinary Bash array assignments  
Category: Arrays  
Impact: Low  
Consensus: High  
Description: Bash compound array assignments separate words according to shell syntax, not comma-list syntax. A comma written into an element is normally part of the element.  
Why: Authors familiar with other languages can accidentally create values such as `one,` rather than elements `one` and `two`.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Arrays.html citeturn504014search0

Name: `$(<file)` is Bash-specific shorthand  
Category: Portability  
Impact: Low  
Consensus: High  
Description: Bash supports `$(<file)` as an optimized way to read a file through command substitution. Do not use it in code that must run under shells that do not implement the extension.  
Why: A compact Bash idiom can become a syntax or semantic failure under a different `sh`.  
Source URL: https://www.shellcheck.net/wiki/SC3034 citeturn220184search25

Name: Process substitution is not portable POSIX `sh`  
Category: Portability  
Impact: Low  
Consensus: High  
Description: `<(...)` and `>(...)` are Bash extensions rather than portable POSIX shell syntax. Use pipes, temporary files, or explicit descriptors when POSIX-shell portability is required.  
Why: Code can work correctly in Bash while failing immediately under another `/bin/sh`.  
Source URL: https://www.shellcheck.net/wiki/SC3001 citeturn220184search5

Name: Here strings are not portable POSIX `sh`  
Category: Portability  
Impact: Low  
Consensus: High  
Description: The `<<<` here-string operator is a Bash feature and should not appear in scripts whose interpreter contract is portable POSIX `sh`.  
Why: Interpreter portability requires portability of syntax, not merely portability of the external commands being invoked.  
Source URL: https://www.shellcheck.net/wiki/SC3011 citeturn359975search1

Name: Prefer `.` to `source` only when POSIX portability is required  
Category: Portability  
Impact: Low  
Consensus: High  
Description: Bash supports both `source file` and `. file`; POSIX specifies the dot command. Bash-targeted code may use either, but portable shell libraries should use `.` and account for its lookup rules.  
Why: `source` unnecessarily makes otherwise-portable shell code Bash-specific.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html citeturn729676search6

Name: Do not expect an alias to accept function-style parameters  
Category: Aliases  
Impact: Low  
Consensus: High  
Description: Aliases perform lexical replacement rather than defining callable parameterized routines. Use a function when reusable behavior needs positional arguments or structured control flow.  
Why: Attempts to embed `$1`, `$2`, and similar parameter logic in aliases do not behave like function calls.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Aliases.html citeturn243606search0

Name: Alias definitions may not take effect inside the same parsed compound command  
Category: Aliases and parsing  
Impact: Low  
Consensus: High  
Description: Bash reads complete compound constructs before executing them, while alias expansion happens during parsing. An alias defined inside such a construct may therefore not affect later text in that already-parsed construct.  
Why: Visually sequential code can behave differently because alias definition and alias use occur at different phases.  
Source URL: https://www.gnu.org/software/bash/manual/html_node/Aliases.html citeturn243606search0

Name: Historical Bash `read -d` behavior had multibyte edge cases  
Category: Version-specific input behavior  
Impact: Low  
Consensus: Low  
Description: Some Bash 5.0 through pre-release 5.3 versions had a multibyte-locale issue involving `read -d` delimiter handling that was corrected in final Bash 5.3. Treat reports involving those versions as version-specific rather than assuming current Bash shares the bug.  
Why: Compatibility workarounds written for the historical behavior may be unnecessary or counterproductive on current Bash.  
Source URL: https://mywiki.wooledge.org/BashPitfalls citeturn532306view7

-----
#### User said:

Using the research findings, write **one single enforceable rule for each finding**.
 
The goal is to convert every identified pitfall, gotcha, footgun, anti-pattern, correctness hazard, or preferred idiom into a concise rule that can be given to an AI coding agent and used to prevent that specific issue.
 
For each finding:
 
 
- Produce exactly **one rule**.
 
- Preserve the intent and technical nuance of the finding.
 
- State the preferred behavior directly.
 
- Include the prohibited or discouraged behavior when necessary to make the rule unambiguous.
 
- Make the rule specific enough to be actionable and reviewable.
 
- Prefer objective, observable requirements over vague advice.
 
- Do not add rationale, explanation, examples, exceptions, or implementation guidance unless they are necessary to make the rule technically correct.
 
- Preserve material conditions or exceptions from the research. Do not turn conditional guidance into an unconditional prohibition.
 
- Do not make a rule stricter than the underlying evidence supports.
 
- Do not combine multiple independent findings into one rule.
 
- Do not split one finding into multiple rules.
 
- Do not invent new requirements that were not supported by the corresponding finding.
 
- Avoid generic wording such as "use best practices," "write clean code," "be careful," or "prefer idiomatic code."
 
- Write the rule so compliance can be determined from the code or relevant development context whenever practical.
 

 
Use normative language consistently:
 
 
- `MUST` for behavior required to avoid a well-supported correctness, safety, or reliability problem.
 
- `MUST NOT` for behavior that is prohibited under the applicable conditions.
 
- `SHOULD` / `SHOULD NOT` for strong preferences where legitimate exceptions exist.
 
- `MAY` only when expressing an explicitly permitted alternative is necessary.
 

 
Determine the strength of each rule from the underlying **Impact**, **Consensus**, evidence, and stated exceptions. Do not automatically convert every finding into `MUST` or `MUST NOT`.
 
For each finding, output exactly:
 `Name: Rule: ` 
`Name` must preserve the name of the original research finding so the rule can be traced back to it.
 
`Rule` must contain the single resulting rule.
 
Process **every finding** from the research. Do not omit findings merely because they are low impact, low consensus, conditional, or stylistic. Where the evidence does not justify a strict requirement, express the rule with appropriately weaker normative language.
 
Avoid duplicate rules. If separate research findings ultimately impose the same requirement, retain their traceability but do not broaden either rule beyond its original finding.

-----
#### Assistant said:

I’ll preserve every original finding name and convert each independently, including the conditional and lower-consensus cases where the correct rule strength is `SHOULD` rather than `MUST`.

-----
#### Assistant said:

Name: Quote expansions that should remain one argument  
Rule: Parameter expansions and command substitutions intended to produce one argument `MUST` be double-quoted.

Name: Preserve argument boundaries with `"$@"`  
Rule: Positional parameters forwarded as separate arguments `MUST` use `"$@"`; unquoted `$@`, `$*`, and `"$*"` `MUST NOT` be used when original argument boundaries must be preserved.

Name: Do not parse `ls` or newline-delimited output as filenames  
Rule: Arbitrary filenames `MUST NOT` be parsed from `ls` output or whitespace/newline-delimited command substitution; pathname-aware or NUL-safe mechanisms `MUST` be used instead.

Name: Protect operands that begin with `-`  
Rule: Operands that may begin with `-` `MUST` be protected from option parsing with `--` where supported or an unambiguous pathname form such as an absolute path or `./` prefix.

Name: Use arrays for dynamically constructed argument lists  
Rule: Dynamically constructed command arguments `MUST` be stored and expanded as an array rather than encoded as a shell-quoted command string.

Name: Avoid `eval` for data-driven command construction  
Rule: `eval` `MUST NOT` be used merely to construct commands, assignments, or argument lists from data when direct shell constructs can represent the operation, and untrusted data `MUST NOT` be passed through `eval`.

Name: Do not accidentally execute command-substitution output  
Rule: Command substitution output `MUST NOT` be placed in command position unless executing the produced command and arguments is explicitly intended.

Name: Treat arithmetic contexts as evaluation contexts  
Rule: Untrusted values `MUST` be validated or constrained before use in arithmetic expressions, arithmetic commands, or array subscript contexts that perform arithmetic evaluation.

Name: Pass `find -exec sh -c` operands as arguments  
Rule: Pathnames supplied by `find` to `sh -c` `MUST` be passed as positional arguments and `MUST NOT` be interpolated into the shell program text.

Name: Use NUL-safe interfaces for arbitrary pathnames  
Rule: Streams containing arbitrary pathnames `MUST` use direct pathname interfaces or NUL-delimited transport rather than newline, whitespace, or other pathname-valid delimiters.

Name: Create temporary resources atomically  
Rule: Temporary files or directories in shared writable locations `MUST` be created with an atomic facility such as `mktemp` and `MUST NOT` use predictable names.

Name: Check `cd` before operating on relative paths  
Rule: A `cd` whose success determines the meaning of subsequent relative paths `MUST` be checked for success before those operations execute.

Name: Fail closed on empty destructive path variables  
Rule: Variables used to construct destructive filesystem targets `MUST` be validated as present and acceptable before the destructive command executes.

Name: Do not read and overwrite the same file through one pipeline  
Rule: A transformation `MUST NOT` read a file while simultaneously redirecting pipeline output to that same file; output `MUST` be written separately and committed after successful processing.

Name: Remember that output redirection truncates before command execution  
Rule: When existing target contents must survive command startup or failure, code `MUST NOT` overwrite the target directly with `>` and `MUST` write to a separate target before replacement.

Name: `sudo` does not elevate shell redirections  
Rule: Redirections requiring elevated privileges `MUST` be performed within the elevated execution context and `MUST NOT` rely on `sudo command > privileged_file` to elevate the redirection.

Name: Account for local expansion in SSH command strings  
Rule: SSH command construction `MUST` account for both local and remote shell parsing, and data `MUST NOT` be interpolated into remote shell source in a form that can be reinterpreted as shell syntax.

Name: Quote remote here-document delimiters when expansion belongs remotely  
Rule: A here-document sent to a remote shell `MUST` use a locally quoted delimiter when its expansions are intended to occur on the remote host.

Name: Do not expect pipeline loop mutations to survive  
Rule: Code that requires variable mutations from a loop to persist in the parent shell `MUST NOT` place that loop in a pipeline unless it deliberately depends on configured parent-shell pipeline behavior such as `lastpipe`.

Name: Do not assume pipeline success means every stage succeeded  
Rule: When failure of any pipeline stage matters, code `MUST` inspect or propagate all relevant stage statuses and `MUST NOT` rely solely on the pipeline's default final-command status.

Name: `&` does not report the background command's final status  
Rule: When a background command's eventual success matters, its PID `MUST` be retained and its completion status `MUST` be obtained with `wait`.

Name: Do not assume process substitution contributes to command status  
Rule: When a process-substitution command's success matters, its status `MUST` be synchronized and checked explicitly rather than inferred from the surrounding command's status.

Name: Separate declaration from status-sensitive command substitution  
Rule: When a command substitution's exit status matters, declaration or attribute-setting builtins such as `local`, `declare`, `export`, or `readonly` `MUST` be separated from the assignment.

Name: Do not store arbitrary binary data in Bash variables  
Rule: Arbitrary binary data that may contain NUL bytes `MUST NOT` be stored in Bash variables.

Name: Use `IFS= read -r` for literal text lines  
Rule: Lines whose leading/trailing whitespace and backslashes are data `MUST` be read with `IFS= read -r` or an equivalent mechanism that preserves them.

Name: Prevent commands inside `while read` from stealing loop input  
Rule: Commands executed inside an input-reading loop `MUST NOT` consume the loop's input stream unless that consumption is intentional; their stdin or the loop's file descriptor `MUST` be isolated when necessary.

Name: Quote here-document delimiters for literal bodies  
Rule: A here-document whose body must remain literal `MUST` use a quoted delimiter.

Name: Declare the interpreter that matches the script language  
Rule: Scripts using Bash-specific syntax or semantics `MUST` declare Bash as their interpreter, while scripts declaring POSIX `sh` `MUST NOT` depend on Bash-specific language features.

Name: Do not run a Bash script as `sh script`  
Rule: A script requiring Bash syntax or semantics `MUST NOT` be invoked with `sh`; it `MUST` be executed through Bash or its Bash shebang.

Name: Redirection order is significant  
Rule: Multiple redirections `MUST` be ordered according to Bash's left-to-right redirection semantics and `MUST NOT` be treated as commutative.

Name: Never use uncontrolled text as a `printf` format string  
Rule: Uncontrolled or data-derived text `MUST NOT` be used as the `printf` format argument; a fixed format string `MUST` be used instead.

Name: Quote `"${array[@]}"` to preserve elements  
Rule: Expanding all array elements while preserving their element boundaries `MUST` use `"${array[@]}"`.

Name: Do not populate arrays with unquoted command substitution  
Rule: Structured command output `MUST NOT` be loaded into an array with unquoted command substitution such as `array=( $(command) )`; a record-aware input mechanism `MUST` be used.

Name: Do not `source` untrusted configuration files  
Rule: Files containing untrusted configuration data `MUST NOT` be loaded with `source` or `.` unless executing them as arbitrary shell code is explicitly intended.

Name: Use an explicit path when sourcing a specific file  
Rule: When a specific file must be sourced, its path `MUST` be explicit rather than relying on `PATH`-dependent source lookup.

Name: Account for `BASH_ENV` in non-interactive execution  
Rule: Security-sensitive non-interactive Bash execution `MUST NOT` inherit an uncontrolled `BASH_ENV`; it `MUST` be unset or constrained before Bash startup.

Name: Control command lookup in security-sensitive scripts  
Rule: Security-sensitive Bash execution `MUST` use a trusted `PATH` or explicit executable paths and `MUST NOT` rely on an uncontrolled inherited command-search path.

Name: Remember that globs are expanded before `sudo`  
Rule: Pathname expansion requiring elevated directory access `MUST` occur within the privileged execution context and `MUST NOT` rely on a glob expanded by the unprivileged invoking shell.

Name: Do not treat `set -e` as complete error handling  
Rule: Scripts `MAY` use `set -e` as a guardrail but `MUST NOT` rely on it as the sole failure handling for operations whose failure must abort or alter execution.

Name: `errexit` changes inside conditions and command substitutions  
Rule: Code that depends on `errexit` `MUST` explicitly account for contexts where Bash suppresses or clears it, including tested commands and command substitutions, rather than assuming uniform termination behavior.

Name: Do not enable `pipefail` blindly around early-exiting consumers  
Rule: Pipelines with consumers that may intentionally terminate early `MUST` account for resulting upstream SIGPIPE statuses before treating `pipefail` failure as an operation failure.

Name: Do not treat `ERR` as a universal exception trap  
Rule: An `ERR` trap `MUST NOT` be used as the sole mechanism for handling failures that must always be detected.

Name: Treat associative-array subscripts as version-sensitive evaluation contexts  
Rule: Untrusted associative-array keys `SHOULD NOT` be placed directly into arithmetic or other repeatedly evaluated subscript expressions when supported Bash versions may exhibit repeated subscript evaluation.

Name: Command substitution removes trailing newlines  
Rule: Command substitution `MUST NOT` be used when preserving trailing newline characters from command output is required.

Name: Here strings append a newline  
Rule: Here strings `MUST NOT` be used when the supplied byte stream must exactly equal the source value without an appended newline.

Name: Quote variables used with `[ ... ]`  
Rule: Variable operands passed to `[` or `test` `MUST` be quoted where word splitting or pathname expansion could alter the intended argument structure.

Name: Prefer `[[ ... ]]` for Bash-native string tests  
Rule: Bash-specific code `SHOULD` use `[[ ... ]]` for shell-native string and pattern tests unless POSIX `sh` portability or another material constraint requires `[` or `test`.

Name: Quote the right side of `[[ = ]]` for literal equality  
Rule: The right-hand operand of `[[ ... = ... ]]` `MUST` be quoted when literal equality rather than pattern matching is intended.

Name: Do not quote a regex variable when regex matching is intended  
Rule: A variable containing an intended regular expression `MUST NOT` be wholly quoted on the right side of `[[ ... =~ ... ]]` when regex interpretation is required.

Name: Distinguish invalid regex from no regex match  
Rule: When a dynamically supplied regex may be invalid and that condition matters, code `MUST` distinguish `=~` status 2 from ordinary no-match status 1.

Name: Copy `BASH_REMATCH` before another regex match  
Rule: `BASH_REMATCH` values needed after a subsequent regex operation `MUST` be copied before that operation occurs.

Name: Use arithmetic comparison for numbers  
Rule: Values intended to be compared numerically `MUST` use arithmetic or numeric comparison operators rather than lexicographic string ordering.

Name: Avoid `-a` and `-o` inside `test` expressions  
Rule: Compound conditions `SHOULD NOT` use `-a` or `-o` inside `[` or `test`; separate shell conditionals or `[[ ... ]]` `SHOULD` be used instead.

Name: `[ false ]` is true  
Rule: A one-argument `[` or `test` expression `MUST NOT` be used to interpret boolean-looking strings such as `false` or `0`; commands or explicit value comparisons `MUST` be used.

Name: Test a command by running it  
Rule: Command success in a conditional `SHOULD` be tested by using the command directly as the condition rather than running it first and inspecting `$?` later.

Name: `A && B || C` is not a general ternary expression  
Rule: `A && B || C` `MUST NOT` be used as an `if`/`else` substitute when `C` should execute only if `A` fails, because failure of `B` also causes `C` to run.

Name: Capture `$?` before running anything else  
Rule: When `$?` must be inspected, it `MUST` be read or saved immediately after the command whose status is required.

Name: Capture `PIPESTATUS` immediately  
Rule: Required `PIPESTATUS` values `MUST` be copied before executing any subsequent command or pipeline.

Name: Remember that `((i++))` can return failure  
Rule: `((i++))` `MUST NOT` be used where its status 1 result for an initial zero value would incorrectly trigger `errexit`, conditional chaining, or failure handling.

Name: Distinguish unset from empty in parameter defaults  
Rule: Parameter-default operators `MUST` use the colon form only when unset and empty values are intended to receive the same treatment; the non-colon form `MUST` be used when an explicitly empty value must be preserved.

Name: Quote literal variables inside parameter-removal patterns  
Rule: Variable expansions used as literal prefix or suffix text in parameter-removal patterns `MUST` be quoted within the parameter expansion so their glob characters are not interpreted as pattern syntax.

Name: Remember that `case` operands are patterns  
Rule: Expanded values used in `case` pattern positions `MUST` be quoted when their contents are intended to match literally rather than as shell patterns.

Name: Handle unmatched globs explicitly  
Rule: Code whose correctness depends on the zero-match case for a glob `MUST` explicitly define or handle unmatched-glob behavior rather than assume the pattern disappears.

Name: Scope `nullglob` and `failglob` deliberately  
Rule: Changes to `nullglob` or `failglob` `MUST` be scoped or restored when they are not intended to affect subsequent shell code.

Name: Decide explicitly whether globs should include dotfiles  
Rule: Code whose correctness depends on including or excluding leading-dot names `MUST` explicitly account for Bash's dotfile globbing behavior.

Name: Avoid hidden dependence on `GLOBIGNORE`  
Rule: Code requiring deterministic pathname expansion `MUST` control or neutralize inherited `GLOBIGNORE` state.

Name: Enable `extglob` before parsing constructs that use it  
Rule: `extglob` `MUST` be enabled before Bash parses any function body or compound command containing extended-glob syntax.

Name: Control locale when character ranges require ASCII semantics  
Rule: Pattern ranges requiring ASCII byte-order semantics `MUST` execute under a locale that guarantees those semantics, such as `LC_ALL=C`.

Name: Quote patterns intended for another utility  
Rule: Pattern arguments intended to be interpreted by another utility rather than by Bash `MUST` be quoted against shell pathname expansion.

Name: Do not pass an expanding glob to one `test -e` expression  
Rule: `[` or `test` `MUST NOT` receive an unquoted glob as a single file-test operand when that glob may expand to zero or multiple pathnames.

Name: `[[ -e pattern* ]]` does not perform pathname expansion  
Rule: `[[ -e pattern ]]` `MUST NOT` be used to determine whether a pathname glob has matches; the pattern `MUST` be expanded in a pathname-expansion context first.

Name: `-e` is false for a dangling symlink  
Rule: Code that must detect a symlink object even when its target is missing `MUST` use `-L` or `-h` and `MUST NOT` rely on `-e` alone.

Name: Do not treat `IFS=, read` as a CSV parser  
Rule: Data conforming to CSV quoting and escaping rules `MUST NOT` be parsed with `IFS` and `read`; a CSV-aware parser `MUST` be used.

Name: Preserve the distinction between unset and empty `IFS`  
Rule: Temporary `IFS` changes `MUST` preserve the original set-versus-unset state when that distinction may matter, preferably by localizing the change rather than restoring only its string value.

Name: Handle an unterminated final input line when it matters  
Rule: When an unterminated final line is valid input, the read loop `MUST` process a final nonempty value even when `read` reports failure due to missing newline termination.

Name: Indexed-array subscripts are arithmetic expressions  
Rule: Externally supplied indexed-array subscripts `MUST` be validated as acceptable arithmetic input before Bash evaluates them.

Name: Bash indexed arrays are sparse  
Rule: Code `MUST NOT` infer an indexed array's highest index or density from `${#array[@]}`; actual indices `MUST` be used when index positions matter.

Name: `${array}` means element zero, not the whole array  
Rule: Code intending to operate on all array elements `MUST` use an explicit all-elements expansion such as `"${array[@]}"` and `MUST NOT` use `${array}` for that purpose.

Name: Quote array subscripts passed to `unset`  
Rule: Array-element references passed to `unset` `MUST` be quoted or otherwise protected from pathname expansion.

Name: Do not rely on associative-array iteration order  
Rule: Code requiring deterministic associative-array order `MUST` maintain or derive an explicit ordering and `MUST NOT` rely on Bash's observed iteration order.

Name: Bash does not provide true multidimensional arrays  
Rule: Bash code `SHOULD NOT` model substantial nested or multidimensional data by treating Bash arrays as recursively nested structures.

Name: Leading zeroes invoke octal arithmetic  
Rule: Decimal input that may contain leading zeroes `MUST` be validated or normalized before Bash arithmetic so it is not unintentionally interpreted as octal.

Name: Use `10#` carefully for signed decimal input  
Rule: Signed decimal input `MUST NOT` be converted by blindly prepending `10#`; its sign and magnitude `MUST` be handled in a form valid for Bash arithmetic.

Name: Bash arithmetic overflow is not checked  
Rule: Arithmetic whose correctness depends on overflow detection or values beyond Bash's integer range `MUST` use a mechanism that provides the required range or checking and `MUST NOT` assume Bash detects overflow.

Name: Bash arithmetic is integer-only  
Rule: Calculations requiring non-integer arithmetic `MUST` use a numeric facility that supports it rather than Bash arithmetic expansion.

Name: Brace expansion does not use parameter expansion for its bounds  
Rule: Runtime values `MUST NOT` be used as brace-expansion bounds such as `{1..$n}`; dynamic ranges `MUST` use a runtime construct such as arithmetic iteration.

Name: Avoid huge brace expansions  
Rule: Large dynamic or potentially large ranges `SHOULD NOT` be materialized with brace expansion when an iterative or streaming mechanism can avoid generating the entire word list at once.

Name: Bash function locals use dynamic scope  
Rule: Bash functions `MUST NOT` assume lexical isolation of `local` variables and `MUST` account for their visibility to called functions.

Name: `declare` inside a function is local by default  
Rule: A function that intends `declare` to create or modify a global variable `MUST` request global scope explicitly rather than relying on bare `declare`.

Name: Function status defaults to the last command's status  
Rule: A function whose exit status is part of its contract `MUST` establish that status deliberately and `MUST NOT` leave it dependent on an incidental final command.

Name: Positional parameters above 9 require braces  
Rule: Positional parameters numbered 10 or greater `MUST` be referenced with braces, such as `${10}`.

Name: Reset or localize `OPTIND` before reparsing options  
Rule: Each independent or repeated `getopts` parsing pass `MUST` initialize or localize `OPTIND` so it does not inherit parser position from an earlier pass.

Name: Do not return data through shell exit status  
Rule: Shell exit status `MUST` be reserved for status information and `MUST NOT` be used to transport substantive data that cannot be represented reliably in the shell status range.

Name: Quote trap bodies for the intended expansion time  
Rule: Trap commands containing expansions that must occur when the trap fires `MUST` be quoted or constructed so those expansions are deferred until trap execution.

Name: Trap inheritance is option-dependent  
Rule: Code requiring `ERR`, `DEBUG`, or `RETURN` traps inside functions, command substitutions, or subshells `MUST` explicitly configure or install the required trap inheritance and `MUST NOT` assume it occurs automatically.

Name: SIGKILL and SIGSTOP cannot be trapped  
Rule: Required cleanup or integrity guarantees `MUST NOT` depend on trapping `SIGKILL` or `SIGSTOP`.

Name: Prefer signal names over numeric signal values  
Rule: Signal references `SHOULD` use symbolic signal names rather than numeric values when portability matters.

Name: Closing stderr is not equivalent to discarding it  
Rule: Code intending only to suppress stderr `MUST` redirect it to a sink such as `/dev/null` rather than close file descriptor 2, unless closed-descriptor behavior is explicitly intended.

Name: Close dynamically allocated file descriptors when finished  
Rule: Dynamically allocated persistent file descriptors `MUST` be explicitly closed when their intended lifetime ends.

Name: `exec` replaces the shell on success  
Rule: Required commands or cleanup `MUST NOT` be placed after a successful `exec` with the expectation that the shell will resume execution.

Name: Temporary environment assignments do not affect same-command shell expansion  
Rule: When a new variable value must affect shell expansions used in a command's arguments or redirections, the assignment `MUST` occur before that command rather than only as its temporary environment prefix.

Name: Use subshell grouping when temporary state should not escape  
Rule: Shell-state changes that should not escape an operation `SHOULD` be isolated in a subshell when doing so preserves the required behavior.

Name: Do not depend accidentally on `lastpipe`  
Rule: Code requiring the final pipeline component to mutate the parent shell `MUST NOT` depend on `lastpipe` unless that option and its required job-control conditions are explicitly controlled.

Name: Save `$!` immediately for each asynchronous job  
Rule: A background process identifier needed later `MUST` be copied from `$!` before another asynchronous process or applicable process substitution is started.

Name: Background commands may receive `/dev/null` as stdin  
Rule: A background command that requires meaningful standard input `MUST` receive an explicit input source rather than relying on inherited stdin.

Name: Use `BASH_SOURCE` rather than `$0` for the currently sourced Bash file  
Rule: Bash code locating the file that defines the current sourced code or function `MUST` use `BASH_SOURCE` rather than `$0`.

Name: Use `BASHPID` when the current Bash process ID is required  
Rule: Code requiring the PID of the current Bash process `MUST` use `BASHPID` rather than assuming `$$` changes with every Bash subshell context.

Name: Remember that sourcing mutates the current shell  
Rule: Code `MUST NOT` assume `source` or `.` isolates shell state; when sourced code's state changes must not escape, it `MUST` be executed in an isolated shell environment.

Name: Keep the shebang at the beginning of the file  
Rule: An executable shell script's shebang `MUST` be the first line of the file with no preceding blank lines or comments.

Name: Keep shell scripts free of CRLF line endings  
Rule: Shell scripts intended for Unix execution `MUST` use LF rather than CRLF line endings.

Name: Do not assume portable multi-argument shebang parsing  
Rule: Shebangs intended to be portable across Unix-like systems `SHOULD NOT` depend on arbitrary multi-argument interpreter parsing unless all target platforms explicitly support the chosen mechanism.

Name: Prefer functions to aliases in scripts  
Rule: Non-interactive Bash scripts `SHOULD` use functions rather than aliases for reusable or parameterized behavior unless alias-specific parse-time semantics are explicitly required.

Name: Use `command -v` for shell-aware command discovery  
Rule: Shell-aware command discovery `SHOULD` use `command -v` rather than relying on the external `which` utility.

Name: Prefer `printf` to `echo` for predictable output  
Rule: Code requiring predictable or portable literal output `SHOULD` use `printf` with a fixed format rather than `echo`.

Name: Quote `tr` ranges and decide their locale semantics  
Rule: `tr` operands containing ranges or character classes `MUST` be quoted against shell expansion, and code requiring specific ASCII range semantics `MUST` control the applicable locale.

Name: Do not identify processes with `ps | grep`  
Rule: Code that requires reliable process identification `MUST NOT` use `ps | grep`; it `MUST` track known PIDs or use a purpose-built process lookup mechanism.

Name: Do not export `CDPATH` casually  
Rule: Scripts requiring deterministic relative `cd` resolution `MUST` control or neutralize `CDPATH` rather than relying on an uncontrolled inherited value.

Name: Treat shell option changes as shared state  
Rule: Changes made with `set` or `shopt` `MUST` be scoped or restored when they are not intended to affect later code in the same shell.

Name: Bash `=~` uses extended regular expressions, not PCRE  
Rule: Regular expressions used with Bash `=~` `MUST` conform to Bash's supported extended regular-expression semantics and `MUST NOT` rely on PCRE-specific syntax or behavior.

Name: Do not assume `set -u` is universally beneficial strictness  
Rule: `set -u` `SHOULD` be enabled only when the script's unset-value semantics and supported Bash versions are compatible with it, and it `MUST NOT` be treated as universally safe strict-mode behavior.

Name: Treat `noclobber` as a guardrail, not a complete write strategy  
Rule: Code requiring atomic or failure-safe file replacement `MUST NOT` rely solely on `noclobber`; it `MUST` use a write strategy that provides the required integrity guarantees.

Name: Parallel `xargs` jobs can interleave output  
Rule: Parallel `xargs` jobs writing logical records to a shared output stream `MUST` buffer, serialize, or otherwise coordinate publication when record boundaries must remain intact.

Name: `declare -i` turns assignments into arithmetic evaluation  
Rule: Untrusted text `MUST` be validated before assignment to `declare -i` variables because those assignments are evaluated as arithmetic expressions.

Name: Validate names before using namerefs for indirect assignment  
Rule: Nameref target names derived from untrusted or externally supplied data `MUST` be validated and constrained to the variables the operation is permitted to reference.

Name: Prefer `$(...)` to backtick command substitution  
Rule: New Bash code `SHOULD` use `$(...)` rather than backticks for command substitution.

Name: A quoted tilde does not perform tilde expansion  
Rule: A quoted home-directory pathname `MUST` use an expansion such as `"$HOME/..."` rather than `"~/..."` when home-directory expansion is required.

Name: Separate assignment and export when tilde portability matters  
Rule: Portable shell code `SHOULD` separate tilde-containing assignment from `export` rather than relying on shell-specific tilde-expansion behavior inside declaration builtins.

Name: `<<-` strips tabs, not arbitrary indentation  
Rule: Here-documents relying on `<<-` indentation stripping `MUST` use leading tab characters for the indentation to be stripped and `MUST NOT` rely on spaces being removed.

Name: Nothing may follow a line-continuation backslash  
Rule: A backslash used for shell line continuation `MUST` be the final character before the newline.

Name: Comments and backslash continuation interact poorly  
Rule: Comment-only lines `MUST NOT` be inserted within a backslash-continued command when subsequent lines are intended to remain part of that command.

Name: `time` may be a shell reserved word rather than the external utility  
Rule: Code requiring a specific external `time` implementation or its options `MUST` invoke that implementation explicitly rather than assume `time` resolves to the external utility.

Name: Prefer Bash arithmetic and parameter expansion to `expr`  
Rule: Bash-specific code `SHOULD` use native arithmetic and parameter expansion instead of `expr` for ordinary arithmetic and string operations supported directly by Bash.

Name: Shell functions are not ordinary external executables  
Rule: Code crossing into `sudo`, another shell, or another process `MUST NOT` assume caller-defined shell functions are available there unless their definition or export is explicitly arranged.

Name: Separate a negative substring offset from `:`  
Rule: Negative substring offsets in Bash parameter expansion `MUST` be syntactically separated from `:` so they cannot be parsed as the `:-` default-value operator.

Name: Negative indexed-array subscripts count from the end  
Rule: Code for which negative array indices are invalid `MUST` reject them explicitly and `MUST NOT` assume Bash treats them as invalid subscripts.

Name: Commas are not separators in ordinary Bash array assignments  
Rule: Bash array elements `MUST` be separated by shell word syntax and `MUST NOT` use commas as element separators unless the comma is intentionally part of an element.

Name: `$(<file)` is Bash-specific shorthand  
Rule: Code required to run under portable POSIX `sh` `MUST NOT` use Bash-specific `$(<file)` command-substitution shorthand.

Name: Process substitution is not portable POSIX `sh`  
Rule: Code required to run under portable POSIX `sh` `MUST NOT` use `<(...)` or `>(...)` process substitution.

Name: Here strings are not portable POSIX `sh`  
Rule: Code required to run under portable POSIX `sh` `MUST NOT` use `<<<` here strings.

Name: Prefer `.` to `source` only when POSIX portability is required  
Rule: Shell code required to be POSIX-portable `MUST` use `.` rather than Bash-specific `source`; Bash-only code `MAY` use either.

Name: Do not expect an alias to accept function-style parameters  
Rule: Reusable shell behavior requiring positional parameters `MUST` be implemented as a function or executable command rather than an alias.

Name: Alias definitions may not take effect inside the same parsed compound command  
Rule: Code `MUST NOT` rely on an alias defined inside a compound construct becoming available to later text within that same already-parsed construct.

Name: Historical Bash `read -d` behavior had multibyte edge cases  
Rule: Workarounds for the historical multibyte `read -d` delimiter bug `SHOULD` be conditioned on affected Bash versions and `SHOULD NOT` be applied unconditionally to Bash 5.3 or later.
