
## C-to-Isabelle and AutoCorres applied on Openbsd driver

These are the settings required to install C-to-Isabelle parser and AutoCorres tool.

These will be used from Jedit (an IDE for Isabelle).

## Installation

### Dependencies
For Ubuntu use the commands bellow:

_For other systems (Debian/MacOS) see: https://github.com/seL4/l4v/blob/master/docs/setup.md_

    sudo apt-get install \
    python3 python3-pip python3-dev \
    gcc-arm-none-eabi build-essential libxml2-utils ccache \
    ncurses-dev librsvg2-bin device-tree-compiler cmake \
    ninja-build curl zlib1g-dev texlive-fonts-recommended \
    texlive-latex-extra texlive-metapost texlive-bibtex-extra \
    mlton-compiler haskell-stack &&
    stack upgrade --binary-only
    

The build system for the seL4 kernel requires several python packages:

    sudo pip3 install --upgrade pip
    sudo pip3 install sel4-deps
    

### Repo download
Download the L4v sources using git-repo tool:

_source: https://github.com/seL4/verification-manifest_

    mkdir verification
    cd verification/
    

Because of some error (maybe caused by a different combination of versions of python and git-repo): 

    File "/home/user/verification/.repo/repo/main.py", line 79
        file=sys.stderr)
        ^
    SyntaxError: invalid syntax
    

Download and install git-repo from here:

    curl https://storage.googleapis.com/git-repo-downloads/repo-1 > repo
    sudo mv repo /usr/bin/
    python3 /usr/bin/repo init -u https://github.com/seL4/verification-manifest.git
    python3 /usr/bin/repo sync
    

### Isabelle installation

_source: https://github.com/seL4/l4v/blob/master/docs/setup.md_

To set up Isabelle for use in l4v/, assuming you have no previous installation of Isabelle, run the following commands:

    cd verification/l4v
    mkdir -p ~/.isabelle/etc
    cp -i misc/etc/settings ~/.isabelle/etc/settings
    ./isabelle/bin/isabelle components -a
    ./isabelle/bin/isabelle jedit -bf
    ./isabelle/bin/isabelle build -bv HOL-Word
    

Building CParser proof:
_source: https://github.com/seL4/l4v_

    ./run_tests -v CParser
    

Start Isabelle Jedit: 

    ./isabelle/bin/isabelle jedit -d . -l CParser
    