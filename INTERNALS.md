# Grade Internals

This document gives an overview of what `grade` does when it's run. You'll need to be familiar with [how `grade` works from a user's perspective](README.md) and [how hooks work](HOOKS.md) to fully understand it.



## Internal Environment Variables

In addition to the [public-facing `GRADE_PATH`](share/man/man1/grade.1.md#description), the following environment variables are used by `grade` internally:

### `GRADE_QUIET`

This is set by passing `-q` or `--quiet` to `grade`.

### `GRADE_VERBOSE`

This is set by passing `-v` or `--verbose` to `grade`.

### `GRADE_TABLE`

`GRADE_TABLE` is a JSON dictionary that holds grading results. When `add_grade` is called, `GRADE_TABLE` is updated; when `print_grade` is called, it's read and printed in a human-friendly format.

The dictionary contained in `GRADE_TABLE` has four keys, one for success and one for failure for calls to each `question` and `extra_credit`:

| The key... | Means that a call to...   | Ended up... |
| ---------- | ------------------------- | ----------- |
| `success`  | `question`                | succeeding  |
| `failure`  | `question`                | failing     |
| `extra`    | `extra_credit`            | succeeding  |
| `missed`   | `extra_credit`            | failing     |

The value corresponding to each of these keys is a list containing each result of a call to `add_grade`. The members of these lists are pairs, the first element being the number of points the question was worth, the second being the question's description.

As an example, if a bash grading script calls:

```bash
question 3 "1 == 0" test 1 -eq 0
```

...when `GRADE_TABLE` isn't set, it will be set (by something along the lines of `export GRADE_TABLE="$(add_grade regular failure 3 "1 == 0")"`) to:

```
{"success": [], "failure": [[3.0, "1 == 0"]], "extra": [], "missed": []}
```



## Program Flow

This explanation follows `grade`'s execution in chronological order.

### Setup

When `grade` starts up, the first thing it does is unset `GRADE_*` environment variables (excluding `GRADE_PATH`) so that it has a clean slate to work from. It then parses command line arguments and sets `GRADE_VERBOSE` or `GRADE_QUIET` if the caller passes `--verbose` or `--quiet`.

### Finding Grading Scripts

`grade` then goes through each directory in `GRADE_PATH`, then the current directory, looking for a match to the command provided by the user. If a `{grade_dir}/whichever/args/were/provided.{hook}` is found for any `hook` in the `grade_dir` being searched, all the `grade-setup.{hook}` scripts in any directories on the way to `provided.{hook}` are put in a list, with `provided.{hook}` then being appended to that list. This list is stored in the environment variable `GRADE_SCRIPTS`, delimited by colons, which is used by `run`.

The loop over `GRADE_PATH` is short-circuited as soon as a grading script (`provided.{hook}`) is found. If no grading script is found in any directory in `GRADE_PATH`, `grade` exits with an error message.

### Running Grading Scripts

The [`run` executable in the appropriate hook directory is executed](HOOKS.md), taking all the arguments that are left from the command line after the name of the grading script. `run` runs each script provided in `GRADE_SCRIPTS`, then runs `print_grade`. The exit value of `run` is used as the exit value of `grade`. TODO: haven't implemented that yet