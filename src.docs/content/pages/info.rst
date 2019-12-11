Vorakl's Bash library
#####################

:slug: info
:summary: Collection of useful modules to simplify everyday programming

|build-status|

Introduction
============

Bash is a powerful programming language and very useful for operational tasks.
Without any doubts, this is the first "tool" for any system administrators of
Unix-like OS's. Although, non-trivial tasks require non-trivial knowledge, and
sometimes it needs more attention on a language specifics than on solving a task
itself. Unfortunately, Bash doesn't have some sort of a "standard library" with
all that functions which make a development process easier, faster and more
efficient in all senses.

|

Suddenly, I realized that I iconstantly use the same functions, same blocks of
code everywhere, and as copy-pasting them from one script to another is not
the right approach, I decided to organize the most used functions in a modules
under one library and place them on a publicly available resource over http.
This makes possible to download them using simple tools or even a pure Bash,
always have the latest version of each module or even get stuck to a specific
version if a reproducibility is needed.

|

This library aims to minimize the complexity of Bash programming by abstracting
special cases, tricky syntax, and commonly used operations behind functions with
a clear interface and intuitive behavior. All modules can be safely embedded in
other's code as all internal names are namespaced by a unique prefix per each
module. 

|

Basically, for me using these modules help to

1. reuse the same code everywhere which is checked and proved by the time
#. simplify and speed up a development
#. increase code readability

|

Modules
=======

* sys_
* str_
* exec_
* matrix_

|

Versions and Releases
=====================

All existing releases including archives are available on
the Github_. Releases are always linked to stable versions.
There are also two version files available:

* latest.lst_,
  for modules located at ``http://bash.libs.cf/latest/``
* stable.lst_,
  for modules located at ``http://bash.libs.cf/stable/``

Versions from ``latest.lst`` allow you to stick to them in the future
by addressing modules at ``http://bash.libs.cf/v?.?.?/`` location.

|

Other documentation
===================

* `Get started`_
* Examples_
* Installation
* Modification of a default configuration

.. |build-status| image:: https://travis-ci.org/vorakl/vbl.svg?branch=master
   :target: https://travis-ci.org/vorakl/vbl
   :alt: Travis CI: continuous integration status

.. Links
.. _sys: {filename}/pages/sys.rst
.. _str: {filename}/pages/str.rst
.. _exec: {filename}/pages/exec.rst
.. _matrix: {filename}/pages/matrix.rst
.. _latest.lst: http://bash.libs.cf/latest.lst
.. _stable.lst: http://bash.libs.cf/stable.lst
.. _Examples: https://github.com/vorakl/vbl/tree/master/examples
.. _Github: https://github.com/vorakl/vbl/releases
.. _`Get started`: {filename}/pages/get-started.rst
