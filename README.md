# connect4


I wrote this program for my CSC 240 class at Mesa Community College.
it has been modified slightly to work in Racket; no other changes have 
been made except for the intro comments.
This program will define several functions to work with a matrix
and allow a user to play a game of connect four
The requirements stated that all functions must begin with the 
programmer's initials; that is why they all begin with 'abs'.
Also, the first two sections of functions were required to have
the same name and purpose, although implementation was up to us.
We were allowed only one variable (besides parameters), and that
is the game board (absGame). We were only allowed to import one 
library, a random number generator
We were also required to have a unique intro message so that we
could distinguish our program from other students' programs.
The goal was to have the best AI, and win the class Connect Four 
Tournament. My program won.

Note: this program uses animation, and the pause between the frames
is determined by the call to absKillTime, in the function absShowGame2.
To adjust the speed of the animation, change the number in the call.
The call is at line 742

When running the program, play proceeds as follows:
```
>(what you type)
--> output
```
The following is how a human plays against the program
```
>(absStartGame)
--> > Is the force strong with this one?
--> #t
>(absShowGame)
--> lots of spaces, then a game board
>(absMarkMove 4) ;4 can be any number 1-7, as the chosen
                  column for your move
--> 4  ;absMarkMove and absMakeMove will return the 
       ;column number that was played so that two
       ;programs could be played against each other
>(absShowGame)
--> lots of spaces, then an animated game board
>(absMakeMove)
--> whatever column the AI chose
>(absShowGame)
--> lots of spaces, then an animated game board
the following three commands will loop as follows until
the conclusion of the game.
>(absMarkMove <column>)
>(absShowGame)
>(absMakeMove)
>(absShowGame)
```
there are some win checking functions, as follows:
    - (absWinP <column>) will test the current game board to see
                         if the last move resulted in a win
    - (absWillWinP <column>) will test the current game board to
                             see if the given move will result in
                             a win


During the tournament, play was as follows, with the class checking
for wins by eye. Whoever had the better looking game board had
their display function used. 
```
>(aaaStartGame)
>(bbbStartGame)
>(aaaShowGame)
>(bbbShowGame)
<voting for the better looking board; I'll say that aaa had the
    better board>
>(bbbMarkMove (aaaMakeMove)) ;aaa makes a move, and bbb needs to record
                             ;the fact that the other player moved
>(aaaShowGame)               ;show the result of the last move
>(aaaMarkMove (bbbMakeMove)) ;inverse of the last play
>(aaaShowGame)               ;show the result of the last move
```
the last four functions loop until one of the AI's wins
