Kitten
======


This project brings you a GUI for the Git version control system using the KDE4
framework.


## Features ##

* Basic history navigation.
* Stage management.
* Committing.

Please have a look at the [[ToDo]]s for features, that are missing.



## Build instructions ###

For compiling and using this plasmoid you will need:

* KDE 4.3
* Ruby + KDE 4 Ruby bindings

### Install needed packages ###

When using Debian or (K)Ubuntu you can install the necessary packages with
    sudo aptitude install ruby-kde4

### Build it ###

To be able to use Kitten you need to compile Qt's UI and resource descriptions.
You can do this by issuing the following commands on the command line.

    cd /where/you/downloaded/this/app
    make

### Use it ###

You can start Kitten by issuing the following commands on the command line.

    cd /where/you/downloaded/this/app
    ruby main.rb &

## Contact and Support ##

You can find the main repository at:

https://github.com/riyad/kitten-ruby

If have come a across any bug or have suggestions please feel free to mail the authors.
