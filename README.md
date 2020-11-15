# [Vorakl's Bash library](https://vbl.vorakl.com/)

[![build-status](https://travis-ci.org/vorakl/vbl.svg?branch=master)](https://travis-ci.org/vorakl/vbl)

## Community

There are a few options for the communication:

* ``IRC``: [#vbl](https://webchat.freenode.net/?channels=vbl), channel on the Freenode network
* ``Mailing list``: vbl-dev@freelists.org, [subscribe](https://www.freelists.org/list/vbl-dev)

## Introduction

This Bash library aims to minimize the complexity of Bash programming by abstracting
special cases, tricky syntax, and commonly used operations behind functions with
a clear interface and intuitive behavior. All modules can be safely embedded in
other's code as all internal names are namespaced by a unique prefix per each
module. 

Bash is a powerful programming language and very useful for operational tasks.
Without any doubts, this is the first "tool" for any system administrators of
Unix-like OS's. Although, non-trivial tasks require non-trivial knowledge, and
sometimes it needs more attention on a language specifics than on solving a task
itself. Unfortunately, Bash doesn't have some sort of a "Standard library" with
all that functions which make a development process easier, faster and more
efficient in all senses.

Suddenly, I realized that I constantly use the same functions, same blocks of
code everywhere, and as copy-pasting them from one script to another is not
the right approach, I decided to organize the most used functions in a modules
under one library and place them on a publicly available resource over http.
This makes possible to download them using simple tools or even a pure Bash,
always have the latest version of each module or even get stuck to a specific
version if a reproducibility is needed.

## Modules

* [sys](https://github.com/vorakl/bash-libs/tree/master/src.docs/content/pages/sys.rst)
* [str](https://github.com/vorakl/bash-libs/tree/master/src.docs/content/pages/str.rst)
* [exec](https://github.com/vorakl/bash-libs/tree/master/src.docs/content/pages/exec.rst)
* [matrix](https://github.com/vorakl/bash-libs/tree/master/src.docs/content/pages/matrix.rst)

## Versions and Releases

All existing releases including archives are available on 
the [Github](https://github.com/vorakl/vbl/releases). Releases are always linked
to stable versions. There are also two version files available:

* [latest.lst](http://vbl.vorakl.com/latest.lst),
  for modules located at `http://vbl.vorakl.com/latest/`
* [stable.lst](http://vbl.vorakl.com/stable.lst)
  for modules located at `http://vbl.vorakl.com/stable/`

Versions from `stable.lst` allow you to stick to them in the future by addressing
modules at `http://vbl.vorakl.com/v?.?.?/` location.


## Other documentation

* [Get started](https://github.com/vorakl/bash-libs/tree/master/src.docs/content/pages/get-started.rst)
* [Examples](https://github.com/vorakl/bash-libs/tree/master/examples)
* [Installation](https://github.com/vorakl/bash-libs/tree/master/src.docs/content/pages/installation.rst)
* [Configuration](https://github.com/vorakl/bash-libs/tree/master/src.docs/content/pages/configuration.rst)
