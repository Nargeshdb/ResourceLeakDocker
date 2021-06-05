# Artifact for "Lightweight and Modular Resource Leak Verification" (ESEC/FSE 2021)

This file describes the artifact for "Lightweight and Modular Resource Leak
Verification", which will be published at ESEC/FSE 2021. The artifact
contains the implementation of the tool ("Resource Leak Checker", section 7) and the case
study programs used in the experiments in section 8.

The artifact contains a Docker environment to ease reproduction. You
can access it by running the following command on a machine with
Docker installed:

TODO: the command

This command will log you into a bash shell inside the Docker container as the
`fse` user, in the `/home/fse` directory.  All relevant code and scripts are
present within that directory.  We provide saved outputs from our checker for
all the case studies in the same directory, and you can run scripts to
re-generate the outputs if desired (detailed instructions below).

**Note**: running our checker within Docker may require increasing Docker's memory
limit for containers.  We set a memory limit of 14GB for Docker when running the
container.

See the INSTALL.md file for more information on how the Docker image
was produced, and instructions on how to build the tool outside of Docker
(i.e., if you wish to make modifications to the tool or build off of it).

### Contents

The Docker image contains the following 5 git repositories, all under `/home/fse`:
* the Resource Leak Checker tool itself, in the `object-construction-checker` sub-directory. The three
parts of section 3 of the paper correspond to three parts of this repository:
section 3.1 corresponds to the must-call-checker subproject; section 3.2
corresponds to most of the object-construction-checker subproject (this
is our prior work from ICSE 2020, which served as the starting point for
this project); section 3.3 corresponds to the file
`object-construction-checker/src/main/java/org/checkerframework/checker/objectconstruction/MustCallInvokedChecker.java`. The implementations of the
features described in sections 4-6 are scattered throughout these files, as
appropriate.
* the zookeeper case study, in the `zookeeper` sub-directory
* the hbase case study, in the `hbase` sub-directory
* the hadoop case study, in the `hadoop` sub-directory
* the plume-util case study, in the `plume-util` sub-directory

The four case study programs each have the following branches:
* `master`/`baseline`: the original program, before we made any modifications.
These are fixed at the point when we started making edits (i.e., at the commit we
analyzed). This branch is called `master` for zookeeper, hbase, and plume-util;
it is called `baseline` for hadoop.
* `with-checker`: `master`/`baseline` with its build system modified to
run the Resource Leak Checker.
* `with-annotations`: `with-checker` modified by adding annotations.
These versions are the ones we used to collect the results in table 1
(except LoC, which used master).  In this branch, all the warnings that we
triaged as part of our case studies are suppressed using `@SuppressWarnings`
annotations, with comments indicating whether each warning was a true positive
or false positive.
* `no-suppressions`: `with-annotations`, modified to comment out the warning
suppressions.  This branch is useful to see the actual warning messages
emitted by the tool.

In addition, the zookeeper, hbase, and hadoop repositories have three other
branches: `no-lo`, `no-ra`, and `no-af`. Each branch corresponds to
one of the conditions for the ablation study in section 8.2: `no-lo` is set up
to run without lightweight ownership (section 4), `no-ra` without resource
aliasing (section 5), and `no-af` without ownership creation annotations
(section 6).

### How to run the experiments

The scripts you'll need to run the experiments are all present in the
`/home/fse` directory.

#### Kicking the tires

If you just want to make sure that everything **can** run, we suggest running
the following commands.  First, start the Docker image:

TODO: command to start the Docker image

Then, within the Docker image in the initial directory (`/home/fse`), analyze
plume-util: 

```
./run-always-call-on-plume-util.sh
```

Check that you get a "BUILD SUCCESSFUL" message at the end.

Running these commands takes about (TODO: minutes).

#### Case studies in section 8.1

This section describes how the numbers in tables 1 and 2 in section 8.1 were
computed, and describes the scripts you can use to reproduce them.

We have provided the raw output from our tool for the case studies in files
`zookeeper-out`, `hadoop-out`, `hbase-out`, and `plume-util-out` under
`/home/fse`.  These files can be re-generated by running the following commands:

```
git -C zookeeper checkout no-suppressions
./run-always-call-on-zookeeper.sh > zookeeper-out

git -C hadoop checkout no-suppressions
./run-always-call-on-hadoop.sh > hadoop-out

git -C hbase checkout no-suppressions
./run-always-call-on-hbase.sh > hbase-out

git -C plume-util checkout no-suppressions
./run-always-call-on-plume-util.sh > plume-util-out
```

Note that these commands can take a significant time to run for programs other
than plume-util.  See Table 1 in the paper for the wall-clock time required to
run the tool, on an Intel Core i7-10700 CPU running at 2.90GHz with 64GiB of
RAM.  Running within Docker may introduce further slowdowns.

For the Zookeeper case study, to see all the checker's warnings about JDK
classes, run 
```
./errors-without-custom-types.sh zookeeper-out
```

The `zookeeper-out` file contains warnings about JDK clasess and classes
defined in the program; the `errors-without-custom-types.sh` script removes
the warnings about classes defined in the program.

For Hadoop and HBase, the corresponding commands are

```
./warnings-without-custom-types.sh hadoop-out
```

```
./warnings-without-custom-types.sh hbase-out
```

The use of the `errors-without-custom-types.sh` script versus the
`warnings-without-custom-types.sh` script is because of differences in the
build systems:  some of the build systems make the compiler issue
"warnings" instead of "errors", so the post-processing scripts must `grep`
for different things.

Our checker does not issue any warnings or errors about non-JDK classes
in plume-util, so no post-processing script is necessary.

*LoC*: Lines of non-comment, non-blank code were computed using the
[`scc`](https://github.com/boyter/scc) program, which is installed
in the docker image.  To compute LoC, take
the "code" column from the output of:
```
git -C zookeeper checkout master
scc zookeeper/zookeeper-server/src/main/java

git -C hadoop checkout baseline
scc hadoop/hadoop-hdfs-project/hadoop-hdfs/src/main/java

git -C hbase checkout master
scc hbase/hbase-client/src/main/java hbase/hbase-server/src/main/java

git -C plume-util checkout master
scc plume-util/src/main/java
```

*Resources*: The "Resources" column in table 1 is computed by the
checker. It records every resource that it tracks, and then outputs
two lines after completing checking: one that lists the number of
resources it checked, and another that lists the number of verified
resources. To acquire these numbers:
```
./resource-counts.sh zookeeper-out

./resource-counts.sh hadoop-out

./resource-counts.sh hbase-out
```
(See above for instructions on how to generate the `-out` files from scratch.)

The result for Zookeeper is:
```
[WARNING] Found 177 must call obligation(s).
[WARNING] Successfully verified 131 must call obligation(s).
```

The "Resources" column in table 1 corresponds to the first number (181 in the
example).  For Hadoop, the script prints two sets of results like the above; the
second result (corresponding to the `hadoop-hdfs-project/hadoop-hdfs` module,
whose warnings we studied) appears in the paper.  For HBase, the script also
prints two sets of results, corresponding to the `hbase-server` and
`hbase-client` modules.  As we studied the warnings in both of these modules,
the paper contains the sum of the two counts of must call obligations.

*Annos.* and Table 2: use the `anno-counter.sh` script. This script takes
a directory as input, and outputs the count of each annotation
in the directory.  For Zookeeper, you can run `./anno-counter.sh zookeeper` to
get the counts.  For Hadoop, you must run `./anno-counter.sh
hadoop/hadoop-hdfs-project/hadoop-hdfs` to get counts from the HDFS module only.
For HBase, you must run `./anno-counter.sh hbase/hbase-client` and then
`./anno-counter.sh hbase/hbase-server` and then sum the results.

Before running `./anno-counter.sh` on a case study, make sure you're on
the branch you want to measure. Our annotations are on the `with-annotations`
branch of each project; you should expect all 0s if you measure the
`master` or `baseline` branches.

The number in the "annos." column in Table 1 is the sum of
the numbers that are output when the script is run on that program. The numbers
in Table 2 are the sums across all benchmarks in the different annotation
categories. In Table 2, some annotation counts are combined: `@Owning` and
`@NotOwning` are combined in the "@Owning and @NotOwning" row,
`@InheritableMustCall` annotations are included in the `@MustCall` counts,
and `@PolyMustCall` annotations are included in the `@MustCallAlias` counts.
(`@InheritableMustCall` is a version of `@MustCall` that can be inherited by
subclasses when written on a class declaration. Because for technical reasons
Java doesn't allow type annotations---like `@MustCall`---to be inherited,
this other annotation was necessary.) These numbers were summed manually.

For example, the output of running `./anno-counter.sh zookeeper` is:
```
@Owning:
      34
@NotOwning (counted with @Owning):
       8
@EnsuresCalledMethods:
      25
@MustCall:
      13
@InheritableMustCall (counted with @MustCall):
       5
@MustCallAlias:
       4
@PolyMustCall (counted with @MustCallAlias):
       4
@CreatesObligation:
      29
```

The total number of annotations in ZooKeeper is therefore 122 in Table
1, and ZooKeeper contributes 42 to the "@Owning and @NotOwning" row,
22 to the "@MustCall" row, and 8 to the `@MustCallAlias` row in Table
2 (and the amount shown after the annotation name to the other rows).

*Code changes*: these were counted manually using the following procedure:

1. checkout the `with-annotations` branch of the target

2. from the target project's directory corresponding to the module of interest
(e.g. `zookeeper/zookeeper-server`), run this command:

> git diff origin/with-checker -- '*.java'

3. Look through the results and count how many added (in green) lines there
are that do NOT match one of the following conditions (i.e. discard
any lines like the following):

* lines that are blank
* lines that are import statements for annotations
* lines that are comments
* lines that contain only a warning suppression
* lines which changed only to add one or more annotations

For each change, also record the reason for the change.

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
project directories (note that on ZooKeeper these commands give a few duplicates
for true positives, so the numbers in the paper are slightly lower):
```
grep -EoniR "//\s*TP:" * | wc -l
grep -EoniR "//\s*FP:" * | wc -l
```

*Wall-clock time*: the script `build-all-and-collect-timing-info.sh` runs
the typechecker 5 times on each benchmark. The result in the paper was
median of these five runs, on the machine the paper describes. This script
took ~2 hours to run on our hardware.

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
