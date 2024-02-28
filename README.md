# Grade

**A simple, extensible grading framework**

`grade` makes it easy to write automatic grading scripts. This page's primary purpose is to [provide an example of how to use it](#examples); for more detailed documentation, see the [man page](share/man/man1/grade.1.md).

If `grade` doesn't work for you use case, consider [requesting a feature](https://github.com/BYUHPC/grade/issues) or using [`autograder`](https://github.com/zmievsa/autograder), which is significantly more sophisticated.

`grade` requires Python 3.6 or newer to run.



## Example

It's assumed that you're comfortable with using a Linux shell--if you aren't, this probably isn't the program for you anyway.

In this example scenarion, you have tasked students with creating an executable file that prints the arguments provided to it on separate lines, to be named `print-args`. Students get 4 points if `print-args` prints the first argument correctly and 2 points if it prints subsequent arguments correctly. Here's how you might set up the grading:

1. Create a directory for your grading script, which we'll call `/grading`. To avoid needing to be in `/grading` to run the grading script, `export GRADE_PATH=/grading`. [`GRADE_PATH` is a colon-delimited list of directories](share/man/man1/grade.1.md#description) that contain grading scripts.

2. Create the grading script, `/grading/lab/basics.bash`. This will allow you to call `grade lab basics ...`, and allows you to create [setup scripts](share/man/man1/grade.1.md#description) that can make writing subsequent grading scripts easier. Here's `basics.bash`:

```bash
#!/bin/bash
# The first argument provided will be the path to the student's print-args executable
# If no argument is provided, assume that print-args is in this directory
PRINT_ARGS="$(realpath "${1:-./print-args}")"

# Run print-args, store the result, and parse it
RESULT="$("$PRINT_ARGS" "First argument" second "third argument")"
FIRST_LINE="$(head -n 1 <<<"$RESULT")"
OTHER_LINES="$(tail -n 2 <<<"$RESULT")"

# Award 4 points if the first argument is printed correctly
problem 4 "print-args prints the first argument correctly" "$FIRST_LINE" == "First argument"

# Award 2 points if subsequent arguments are printed correctly
problem 2 "print-args prints the first argument correctly" "$OTHER_LINES" == "second
third argument"
```

3. Run `grade --verbose lab basics student/submission/directory/print-args`, which will [provide the functions `problem` and `extra_credit`](share/man/man1/grade.1.md#question-and-extra_credit) to your `basics.bash`, run `basics.bash`, and print the results of the calls to `problem` along with a total score.



## Testing and Installation

`make test` will run a few rudimentary tests.

`make install [DESTDIR=/some/directory]` will install `grade` in `DESTDIR`, which defaults to `/`. If you're building from Git rather than one of the [releases](https://github.com/BYUHPC/grade/releases), you'll need Pandoc installed to generate the man page.

To generate a release tarball, use `make distrib`, which will create `grade-$VERSION.tar.gz`.



## Safety

`grade` has no built-in protection against student malice--if a shell script that you're grading contains `rm -rf ~`, your home directory will be wiped if you haven't taken precautions. Using [`safely`](https://github.com/BYUHPC/safely), running in a container, or similar is recommended.



## Future work

This is just a personal project that I figured might be useful for other people; it isn't yet robust or versatile. If there's something that `grade` doesn't do that you would like it to, don't hesitate to [open an issue](https://github.com/BYUHPC/grade/issues).

It's easy to [create new hooks](HOOKS.md), and [hacking on `grade`](INTERNALS.md) is pretty easy since there's so little code, well under 500 lines. [Pull requests](https://github.com/BYUHPC/grade/pulls) are welcome.

Here's what needs to happen to improve `grade`:

### Tests

As it stands, the tests of `grade`'s functionality are primitive.

### Compiled Languages

It wouldn't be hard to provide a C header that provides an interface to `grade` that's similar to what the scripting language hooks provide. Making it behave similarly to [Catch2](https://github.com/catchorg/Catch2) seems reasonable. Other libraries could just call the C bindings, or have their own if it's simple enough.

`grade` is not set up for performance and likely won't ever be *fast* without major architectural changes, but it could probably be sped up significantly by translating at least [`add_grade`](libexec/add_grade) and [`print_grade`](libexec/print_grade) to a compiled language.

### Setup Script/Config File

Having a setup script that sets `GRADE_PATH` would be convenient for some users. Defaulting to `/etc/grade.conf` is my inclination. This will probably become more necessary as `grade` grows in capability and complexity.

### Installation

Using autoconf or CMake rather than a sloppy [Makefile](Makefile) is a good idea.
