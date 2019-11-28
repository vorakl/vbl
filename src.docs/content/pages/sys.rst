sys
###

:slug: sys
:summary: Essential system functions


API
===

* `__sys_version`_ <var>
* `__sys_exported`_ <var>
* `__sys_init__`_ <func>
* `sys_cmd`_  <func>


USAGE
=====

source module_name [list of functions to export]

Example:
--------

.. code-block:: bash                                                            
                                                                                
    #!/bin/bash

    start() {
        source /path/to/sys sys_cmd
    }

    start


__sys_version
=============

__sys_exported
==============

__sys_init__
============

sys_cmd
=======

