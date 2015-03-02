;Adam Sinck
;These are a bunch of functions that I wrote to make gameplay
;easier. Loading this file will automatically load the other
;file. This program does not effect gameplay in any way but to
;make it more user friendly.

;I have adjusted this file to work with racket. To use a command line, 
;uncomment lines 44, 51, and 58 in this program, and the first line in
;connect4.scm

;To play against the computer:
;>(pBegin) ;start the game
;>(play N) ;make a move in column N
;>(play N) ;play until the computer notifies you of a winner

;this will display a help screen
(define (help)
    (begin
	(display "The functions in this program are as follows:") (newline)
	(display "(help)                       Display this help screen") (newline)
	(display "(l)                          Load the game. This is only useful if you're using ") (newline)
	(display "                             a command line to play the game; not for racket") (newline)
	(display "(mark N)                     Mark a move in column N") (newline)
	(display "(markCell row col item)      Mark a cell at (row, col) with a specific piece") (newline)
	(display "(mm)                         Let the AI make a move") (newline)
	(display "(pBegin)                     This will call (l), (start), and (show). (l) will") (newline)
	(display "                             only be called if it has been uncommented, for") (newline)
	(display "                             compatibility with racket") (newline)
	(display "(play N)                     Make a move in column N, and have the AI make a") (newline)
	(display "                             counter move, and display both moves") (newline)
	(display "(playSecond)                 Let the AI make the first move") (newline)
	(display "(playSelf)                   Let the AI play against itself") (newline)
	(display "(prefill)                    Set the game board up in a specific pattern, as coded") (newline)
	(display "(removeTop col)              Take the top piece off of the given column. Useful for ") (newline)
	(display "                             undoing accidental plays") (newline)
	(display "(show)                       Show the board") (newline)
	(display "(start)                      Initialize the game") (newline)
	(display "(toggle)                     Change whose turn it is") (newline)
    )
)



;(load "connect4.scm") ;to be used if not running these programs in racket

;some shorthand for the functions in connect4.scm
(define (mm) (absMakeMove))
(define (show) (absShowGame))
(define (start) (absStartGame))
(define (mark n) (absMarkMove n))
;(define (l) (load "connect4.scm")) ;this function is to be used if using
;the command line for play, but should be commented out if pasting both
;programs into racket.

;this is the first call that is made with this program
(define (pBegin)
    (begin
;	(l)    ; load the program, commented out for racket
	(start); start connect4.scm
	(show) ; show the initial state of the board
    )
)

;this is a function to prefill the board with a specific pattern
;it has been preloaded with an example
(define (prefill)
    (begin
	(mark 4)
	(mark 4)
	(mark 5)
	(mark 5)
	(mark 6)
	(mark 6)
	(mark 3)
    )
)

;this will let the computer play first
(define (playSecond) (begin (mm) (show)))

;this is the main function that you will use. You give (play) the column
;that you want to play in, and it will mark your move, show the animation
;of your piece dropping, and then let the AI take a move and show the AI's 
;piece dropping. If either player has won, it will give a notification.
(define (play n)
    (begin
	(if (absWinP (mark n))
	    (begin
		(show)
		(display "++++++++++++++++++++++++++++++++++\n")
		(display "++++++++++ You have won. +++++++++\n")
		(display "++++++++++++++++++++++++++++++++++\n")
		#t
	    )
	    (begin
		(show)
		(if (absWinP (mm))
		    (begin
			(show)
			(display "//////////////////////////////////\n")
			(display "//////// The computer won. ///////\n")
			(display "//////////////////////////////////\n")
			#t
		    )
		    (begin
			(show)
			(display "No one has won yet.") (newline)
			#t
		    )
		)
	    )
	)
    )
)

;let the computer play against itself, for fun
(define (playSelf)
    (begin
	(if (absWinP (mm))
	    (begin
		(show)
		(display "++++++++++++++++++++++++++++++++++\n")
		(display "+++++++++++++ R won. +++++++++++++\n")
		(display "++++++++++++++++++++++++++++++++++\n")
		#t
	    )
	    (begin
		(show)
		(if (absWinP (mm))
		    (begin
			(show)
			(display "//////////////////////////////////\n")
			(display "///////////// B won. /////////////\n")
			(display "//////////////////////////////////\n")
			#t
		    )
		    (begin
			(show)
			(display "No one has won yet.") (newline)
			#t
		    )
		)
	    )
	)
	(if (absWinP (absGetLastTurn absGame))
	    #t
	    (playSelf)
	)
    )
)

;mark a specific cell with a piece
(define (markCell row col item)
    (set! absGame (absSetCell absGame row col (cons item '())))
)
;change whose turn it is
(define (toggle)
    (set! absGame (absToggle absGame))
)
;take the top piece out from a given column
(define (removeTop col)
    (begin
	(markCell (- (absGetTop absGame col) 1) col "_")
	(absShowBoard absGame)
    )
)
