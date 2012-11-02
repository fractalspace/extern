GIT Extern
-----------

A simple script to manage multiple sub-repos concurrently, similar to svn:externs.
Using this tool, you can manage one or more 'sub repos' inside a 'super repo'.

It consists of 2 files, both part of the super repo:
1) .extern
2) repoinit.sh

The user will clone the super repo, as usual. Immediately followed by running the 'repoinit.sh' script.
The later will read the .extern file, to identify sub repo(s). These sub repo(s) will be cloned into
a folder inside the root folder of the super repo.

Following this step, the script will initiazlie some additional command aliases. These command aliases
will perform composite actions on both repose. The aliases are named by appending 'm' to the underlying
singular git command. e.g 'mpull' will be a composite git command, that will perform 'pull' operation
on the super repo, and then on the sub repo(s).

