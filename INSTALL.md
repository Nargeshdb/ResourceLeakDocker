#### Reproducing our results

To reproduce our results, you can use our docker image. Install Docker,
then run the following command to run our image:

```
(TODO: exact docker command)
```

Then, follow the instructions in README.md.

#### Kicking the tires

(This section duplicates the section with the same name in README.md)

If you just want to make sure that everything **can** run, we suggest running
the following commands and checking that you get a "build succeeded" message
at the end:
(TODO: exact commands to start the docker image and then run the checker on
plume-util)

Running these commands on a fresh machine for us took about (TODO: minutes).
These commands start the docker image and run our tool on the plume-util
microbenchmark.

#### Extending our work

To make modifications to the tool used in the docker image, look at
the `object-construction-checker` sibling directory of the case study
projects. This directory contains the source code for the tool; you
can also find its test suite (a set of simple Java programs with
expected errors) in the `object-construction-checker/tests/mustcall`
and `object-construction-checker/tests/socket` subdirectories. To run
the tests, run `./gradlew build` from the root directory. You can add
new tests by placing them in one of these directories, if you want to
see how the tool works on small examples.

Going forward, we will maintain the tool described in this paper as
part of the Checker Framework (checkerframework.org); the main part of
the tool is currently under review here:
https://github.com/typetools/checker-framework/pull/4687.  (Some
parts, such as the Must Call Checker described in section 3.1 of the
paper, are already part of the Checker Framework.)  Future researchers
who wish to build on or compare against our tool should use the
version that will appear in the Checker Framework (under the name
"Resource Leak Checker").