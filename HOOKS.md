# Grade Hooks

Hooks are interfaces between `grade` and the grading scripts written by its users. Creating a hook involves creating a `language-name` directory in [`libexec/grade_hooks`](libexec/grade_hooks) and placing an executable `run` script there. The `run` script should:

1. Provide the functions `problem` and `extra_credit`; their signatures are arbitrary, but it's best to follow the conventions [outlined on the man page](share/man/man1/grade.1.md). `problem` and `extra_credit` will call the `add_grade` executable, storing its stdout in the environment variable `GRADE_TABLE`. `add_grade` takes 4 arguments:
    1. "regular" for `problem` or "extra_credit" for `extra_credit`
    1. "success" on correct behavior or "failure" on incorrect behavior
    1. The number of points, a non-negative real number
    1. A description of the problem
1. `source` (or the language equivalent) each grading script stored in the colon-delimited environment variable `GRADE_SCRIPTS`.
1. Run `print_grade`, which will parse `GRADE_TABLE` and print it in human-readable form.

Using the provided [Bash](libexec/grade_hooks/bash/run), [Julia](libexec/grade_hooks/julia/run), and [Python](libexec/grade_hooks/python/run) hooks as examples, it shouldn't be too hard to create a new one; for example, to create the Python hook, I just asked ChatGPT to translate the Julia hook and made a couple of minor modifications.