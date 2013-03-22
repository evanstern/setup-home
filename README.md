setup-home
==========

Contains most of the setup scripts and common files I use in my linux home directory.

# Install

It's all pretty manual at the moment. Here's a general checklist:

* copy/link home/bin to ~/ and ensure the contents are executable
* copy/link home/.vim to ~/
* from inside ~/.vim run: `$ git submodule update --init`
* from inside ~/.vim/bundle/jedi-vim run: `$ git submodule update --init`
* from the home directory, copy/link all dot-files to the ~/ directory

