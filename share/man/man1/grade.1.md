---
title: GRADE
section: 1
header: BYU Office of Research Computing
footer: grade @VERSION
date: @DATE
---



# NAME

`grade` - A simple, extensible grading framework.



# SYNOPSIS

`grade [-h] [-v | -q] path [arg...]`



# DESCRIPTION

At its most basic, `grade` provides the functions `question` and `extra_credit`, sources a user-provided script, and prints the results of calls to each function in a user-friendly way. These functions are provided in multiple scripting languages, and all an end user needs to do is provide a script that calls `question` and/or `extra_credit` at least once. The grading script's name should end with `.$extension`, where `extension` is the name of one of the provided hooks (`bash`, `python`, and `julia` by default) and needs to be in the current working directory unless further setup is done. For example, to run the Python grading script:

```python
question(1, "== works", 1 == 1) # 1 point for == working
question(2, "< works",  1 <  2) # 2 points for < working
question(2, "> works",  2 >  1) # 2 points for > working
```

...one could name it `test-python-operators.python`, navigate to the directory containing it, and run `grade test-python-operators`.

Arguments can be passed to the grading script by providing them after the name of the script:

```bash
cat > is-character-special.bash << EOF
USER_PROVIDED_PATH="$1"
question 2 "The argument provided by the user is a block device" test -b "$USER_PROVIDED_PATH"
EOF
grade is-character-special /dev/null # 2/2 points
grade is-character-special /         # 0/2 points
```

To make setup for multiple assignments easier, a `grade-setup.$extension` script can be placed in the same directory as the grading script, in which case it will be run just before the grading script, and with the same arguments. This gives you the ability to avoid duplication of boilerplate--if there's a `question` common to all of the Julia grading scripts in the directory `gradedir`, you can put it in `gradedir/grade-setup.julia`

The utility of `grade-setup.$extension` scripts is enhanced by their ability to nest to arbitrary directory depth. To use the setup scripts leading to the directory containing the grading script, specify the path to said directory (separated out into a separate argument for each directory level) before the name of the grading script. For example, given the directory structure:

```
practice
|-- grade-setup.julia
`-- lab
    |-- 1.julia
    |-- 2.python
    |-- 3.julia
    |-- grade-setup.julia
    `-- grade-setup.python
```

...one would use:

```bash
grade practice lab 1 test
```

...to run `1.julia` with the argument `test`. The setup scripts run first, though--`practice/grade-setup.julia test` is run, then `practice/lab/grade-setup.julia test`, then `1.julia test`.

The environment variable `GRADE_PATH` is a colon-delimited list of paths to search before the current directory. If it is set, grading scripts can be placed within a directory it contains to allay the need to navigate to that directory before running `grade`.



# QUESTION AND EXTRA_CREDIT

Both earned and possible points are tracked by `grade`. After all setup scripts and the grading script are run, both numbers are printed in the form:

```
TOTAL: earned/possible
```

`question` will add to both earned and possible points on success, and only to possible points on failure.

`extra_credit` will add earned points on success, but will never add to possible points.

In Python and Julia, `question` and `extra_credit` are called as:

```python
question(    points, description, success)
extra_credit(points, description, success)
```

In Bash, they are called as:

```bash
question     $points $description $arg1 [$arg2 ...]
extra_credit $points $description $arg1 [$arg2 ...]
```

`points` is a floating point number and `description` is a string. In Python and Julia, `success` is a boolean; the points are awarded only if it's true. In bash, the arguments after `$description` are treated as a command to be run; the points are awarded only if that command's exit code is 0.



# OPTIONS

`-h, --help`
: Show the help message and exit

`-v, --verbose`
: Print verbose output

`-q, --quiet`
: Only print output from grading and setup scripts and the final score



# BUGS AND QUIRKS

There's no build-in protection from malice--if a disgruntled student puts `rm -r $HOME/*` in a script that you're  grading, you may be in for a bad time. Running in a chroot or a container is encouraged.

`grade` uses tput to color its output, so it may mess up your terminal colors if you're doing anything unconventional.

The setup and grading scripts are `source`d (or the language equivalent) by `grade`, so be careful--calling `exit` in a grading script, for example, will halt the execution of `grade`.



# AUTHORS

Michael Greenburg, BYU Office of Research Computing (michael_greenburg@byu.edu, rcsupport@byu.edu)

If you discover a problem with `grade` or have an enhancement to suggest, please open an issue, create a pull request, or email me or one of my colleages.



# SEE ALSO

If you feel limited by `grade`, consider using `autograder`, which is much more sophisticated at the exponse of a bit more complexity: https://github.com/zmievsa/autograder

More extensive documentation, including material on how to build custom hooks and on the internal workings of `grade`, is available at https://github.com/BYUHPC/grade
