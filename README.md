# Artifact for "Lightweight and Modular Resource Leak Verification" (FSE 2021)

This file describes the artifact for "Lightweight and Modular Resource
Leak Verification", which will be published at FSE 2021. The artifact
contains the implementation of the tool described in the paper
("Plumber", section 7) as well as the case study programs used in the
experiments in section 8.

The artifact contains a Docker environment to ease reproduction. You
can access it by running the following command on a machine with
Docker installed:

TODO: the command

See the INSTALLATION.md file for more information on how the Docker image
was produced, and instructions on how to build the tool outside of Docker
(i.e., if you wish to make modifications to the tool or build off of it).

### Contents

The Docker image contains the following 5 git repositories:
* the Plumber tool itself, in the (TODO: absolute path) directory. The three
parts of section 3 of the paper correspond to three parts of this repository:
section 3.1 corresponds to the must-call-checker subproject; section 3.2
corresponds to most of the object-construction-checker subproject (this
is our prior work from ICSE 2020, which served as the starting point for
this project); section 3.3 corresponds to the file
`object-construction-checker/src/main/java/org/checkerframework/checker/objectconstruction/MustCallInvokedChecker.java`. The implementations of the
features described in sections 4-6 are scattered throughout these files, as
appropriate.
* the zookeeper case study, in (TODO: absolute path)
* the hbase case study, in (TODO: absolute path)
* the hadoop case study, in (TODO: absolute path)
* the plume-util micro-benchmark, in (TODO: absolute path)

The four case study programs each have the following branches:
* `master`/`baseline`: the original program, before we made any modifications.
These are fixed at the point when we started making edits (i.e. at the commit we
analyzed). This branch is called `master` for zookeeper, hbase, and plume-util;
and `baseline` for hadoop.
* `with-checker`: `master`/`baseline` modified with its build system modified to
run Plumber.
* `with-annotations`: `with-checker` modified by adding annotations.
These versions are the ones we used to collect the results in table 1
(except LoC, which used master).

In addition, the three case studies (zookeeper, hbase, hadoop) have three other
branches: `no-lo`, `no-ra`, and `no-af`. Each of these branches correspond to
one of the conditions for the ablation study in section 8.2: `no-lo` is set up
to run without lightweight ownership (section 4), `no-ra` without resource
aliasing (section 5), and `no-af` without ownership creation annotations
(section 6).

### How to run the experiments

The scripts you'll need to run the experiments are all present in the same
directory as the git repositories mentioned above. (TODO: make this true)

#### Kicking the tires

If you just want to make sure that everything **can** run, we suggest running
the following commands and checking that you get a "build succeeded" message
at the end:
(TODO: exact commands to start the docker image and then run the checker on
plume-util)

Running these commands on a fresh machine for us took about (TODO: minutes).

#### Case studies in section 8.1

This section describes how the numbers in tables 1 and 2 in section 8.1 were
computed, and describes the scripts you can use to reproduce them.

There is a script for each case study that runs the appropriate build-system
command named `run-always-call-on-*.sh`, where `*` is the name of the case study
program. These scripts run on whatever branch is currently checked out in
the repository, so for example to run the checker on the version of ZooKeeper
with our annotations, you would run `./run-always-call-on-zookeeper.sh`
after running `git checkout with-annotations` in the `zookeeper` directory.
These scripts produce output that includes errors that our checker issues
about custom classes in the project; in our case studies, we only checked
classes that are defined in the JDK. To remove output about custom classes,
we used the `errors-without-custom-types.sh` and
`warnings-without-custom-types.sh` scripts. These scripts post-process the
result of the `run-always-call-on-*.sh` scripts: `errors-without-custom-types.sh`
post-processes zookeeper, and `warnings-without-custom-types.sh` post-processes
hadoop and hbase. These scripts take a path to the file containing the output
of the `run` script as input. For example, to see errors about JDK classes in
Zookeeper, you would run:
```
./run-always-call-on-zookeeper.sh > zookeeper-out
./errors-without-custom-types.sh zookeeper-out
```

On the `with-annotations` branch, the output of these commands should only include
a failure message from Maven.

To run on hbase or hadoop, use the `warnings-without-custom-types.sh` script
instead of the `errors-without-custom-types.sh` script (because of differences
in the build systems, these projects issue "warnings" instead of "errors", so
the post-processing scripts must `grep` for different things).

*LoC*: Lines of non-comment, non-blank code were computed using the `scc` program
available here: https://github.com/boyter/scc. This program is installed
in the docker image. (TODO: install scc on the docker) To compute LoC, first
checkout the `master` branch of the case study program (`baseline` for hadoop).
Then, `cd` to the `src` directory for the component and run `scc`. The figure
in the paper should be the result in the "code" column.

*Resources*: The "Resources" column in table 1 is computed by the
checker. It records every resource that it tracks, and then outputs
two lines after completing checking: one that lists the number of
resources it checked, and another that lists the number of verified
resources. To acquire these numbers, first run the checker on a case
study program via the appropriate `run-always-call-on-*.sh` script,
and pipe the output to a file. Then, run the `resource-counts.sh`
script on the file. For example, to compute the values for ZooKeeper:
```
./run-always-call-on-zookeeeper.sh &> zookeeper-out
./resource-counts.sh zookeeper-out
```

The result is (TODO: double check these numbers vs the paper):
```
[WARNING] Found 181 must call obligation(s).
[WARNING] Successfully verified 129 must call obligation(s).
```

The "Resources" column in table 1 corresponds to the first number (181 in the
example).

*Annos.* and Table 2: use the `anno-counter.sh` script. This script takes
the name of the case study as input, and outputs the count of each annotation
in the case study. The number in the "annos." column in Table 1 is the sum of
the numbers that are output when the script is run on that program. The numbers
in Table 2 are the sums across all benchmarks in the different annotation
categories. In Table 2, some annotation counts are combined: `@Owning` and
`@NotOwning` are combined in the "@Owning and @NotOwning" row, and
`@InheritableMustCall` annotations are included in the `@MustCall` counts.
(`@InheritableMustCall` is a version of `@MustCall` that can be inherited by
subclasses when written on a class declaration. Because for technical reasons
Java doesn't allow type annotations---like `@MustCall`---to be inherited,
this other annotation was necessary.) These numbers were summed manually.

For example, the output of running `./anno-counter.sh zookeeper` is:
```
@Owning:
33
@NotOwning:
8
@EnsuresCalledMethods:
23
@MustCall:
17
@InheritableMustCall:
5
@MustCallAlias:
4
@CreatesObligation:
35
```

The total number of annotations in ZooKeeper is therefore 125 in Table 1,
and ZooKeeper contributes 41 to the "@Owning and @NotOwning" row and
22 to the "@MustCall" row in Table 2 (and the amount shown after the annotation
name to the other rows).

*Code changes*: these were counted manually using the following procedure:

1. checkout the `with-annotations` branch of the target

2. from the target project's directory corresponding to the module of interest
(e.g. `zookeeper/zookeeper-server`), run this command:

> git diff origin/with-checker -- '*.java'

3. Look through the results and count (I used some scratch paper - the
numbers should be pretty small) how many added (in green) lines there
are that do NOT match one of the following conditions (i.e. discard
any lines like the following):

* lines that are blank
* lines that are import statements for annotations
* lines that are comments
* lines that contain only a warning suppression
* lines which changed only to add one or more annotations

For each change recorded this way, also write down the reason for the change.

*TPs and FPs*: the `with-annotations` branch includes an `@SuppressWarnings`
annotation for each warning that our checker issues about a class defined
in the JDK. Each of these annotations is accompanied by a comment containing
a judgement ("TP" or "FP") and a justification; at least two authors examined
each of these and agreed that the judgement and justification are correct.
To examine these directly, we suggest using `git diff` between the `with-checker`
and `with-annotations` branches, and looking at the lines that include an
`@SuppressWarnings` annotation that the `with-annotations` branch added:
```
git checkout with-annotations
git diff with-checker
```

The number of true/false positives were counted by hand by looking at these
diffs. You can also check the numbers by running these commands in the relevant
project directories (TODO: double-check that these give the expected numbers):
```
grep -EoniR "TP:" * | wc -l
grep -EoniR "FP:" * | wc -l
```

You can also examine the warnings from our check that led to each of these
suppressions by commenting out each warning suppression and then re-running
the checker. Each case study has a branch `no-suppressions` on which we've done
that for each such suppression. Running the checker on that branch and then
applying the appropriate filter script (`errors-without-custom-types.sh` for
ZooKeeper; `warnings-without-custom-types.sh` for hbase and hadoop) will show
the warnings that we examined to make our judgements and justifications.

*Wall-clock time*: the script `build-all-and-collect-timing-info.sh` runs the
typechecker 5 times on each benchmark. The result in the paper was median of these
five runs, on the machine the paper describes. You could run this script if you
really want to, but we don't suggest it (it takes ~2 hours).

#### Ablation study (section 8.2)

There are three scripts that run the ablation study: one for each benchmark
program. Each is named `*-ablation.sh`, where `*` is the name of the benchmark.

Running one of these scripts produces 6 numbers: for each variant, the number
of new warnings introduced when running in that configuration and the number
of old errors that are no longer issued. For each variant, the entry in Table 3
is the difference of these (`no-lo` is the "without LO" column; `no-ra` is the
"without RA" column; `no-af` is the "without CO" column). These scripts take
about 3 times the normal compilation time for the benchmark to run, which can
make them expensive (especially for hadoop, which will take 45+ minutes); see
the "wall-clock time" column of Table 1 and multiply by 3 for an estimate.