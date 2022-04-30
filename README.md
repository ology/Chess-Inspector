Chess::Inspector
====

Visualize move, protection and threat status
----

*Installation*

First, you need to have Perl and the superior package manager, `cpanm`.

    git clone https://github.com/ology/Chess-Inspector.git
    cd Chess-Inspector
    cpanm --installdeps .
    plackup bin/app.pl

Now browse to http://localhost:5000/

*User interface:*

![User interface](https://raw.githubusercontent.com/ology/Chess-Inspector/master/public/images/Chess-Inspector.png)

*Hover over a piece:*

![Hover-Info](https://raw.githubusercontent.com/ology/Chess-Inspector/master/public/images/hover-info.png)
