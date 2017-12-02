---
layout: post
title: "Smudge and clean your git working directory"
categories: [git]
---

Some years ago I learned about **smudging and cleaning data in a git repository**,
a very cool git functionality that I haven't used for a while till last week,
when it came back to my mind for solving a specific need.

Smudge and clean are two functionalities that can be configured via [git
attributes](https://git-scm.com/book/en/v2/Customizing-Git-Git-Attributes).
While git attributes are not a very popular git configuration, it provides
several handy functionalities:

1. **identify files as binary files**: this can be convenient to skip those files in `git show`
and `git diff` output (by default, git does not know how to compare binary files).

1. configure a tool/script for **diffing binary files**: relevant in case you don't want to
skip binary files while checking changes in your working directory but instead
be able to show a meaningful diff information. e.g. In case you want to compare
two versions of a video binary file, you could use
[exiftool](https://www.sno.phy.queensu.ca/~phil/exiftool/) to obtain metadata information
from the two versions and compare it.

1. define merge strategies for specific files/paths.

1. configure your preferences for archiving your repository.

1. update files automatically upon checkout/commit: it's possible to change automatically
the file content right after running `git checkout` or right before running `git commit`.
This is the functionality I will focus on.

### Smudging your checkout

Let's say you need a secret token in your code inside the `config.h` file, you want to
commit that file to the git repository, but you don't want it to contain sensible
information.

Simplest solution would be to create a placeholder (e.g. `{your-secret-token}`)
that should be updated with the right value (e.g. `super-secret-value!`) upon checkout:

```c++
const std::string secretToken = "{your-secret-token}";

# After checkout, the line should be updated to:
const std::string secretToken = "super-secret-value!";
```

As soon as you update the file to include your secret value, the file will be shown
as `modified` in the `git status` command.

Thanks to the smudge filter, you can:

- automate the process, so **the file will be updated automatically upon checkout**.
- prevent the file change to be part of the git diff output.

You need two steps for configuring a smudge filter:

* Identify in `.gitattributes` file the files that should be processed by the filter.
In this simple example we want to process the `config.h` file using a filter
named *updateSecretToken*:

```
# .gitattributes file
config.h filter=updateSecretToken
```

* Define the smudge filter *updateSecretToken*, that will substitute the placeholder
with your secret. This can be done in the git global configuration:

```bash
git config --global filter.updateSecretToken.smudge 'sed "s/{your-secret-token}/super-secret-value!/"'
```

Next time you checkout the `config.h` file, its content will be automatically updated and
your secret will be included in the file.

### Cleaning your commit

As much as you need to update the `config.h` file content upon checkout to include your
secret, it's important as well to update the content before including the file
in the stage area, and put back `{your-secret-token}` instead of `super-secret-value!`. Otherwise,
your secret would be exposed.

For doing it, you can define the clean filter *updateSecretToken*. Similar to
the smudge filter, this can be done in the git global config:

```bash
git config --global filter.updateSecretToken.clean 'sed "s/super-secret-value!/{your-secret-token}/"'
```

![Smudge and clean filters](/gfx/posts/smudge-and-clean/smudge-clean-git-filters.png)

