#lang racket
;comment out the previous line if not running this program in racket

;Adam Sinck
;I wrote this program for my CSC 240 class at Mesa Community College.
;it has been modified slightly to work in Racket; no other changes have 
;been made except for the intro comments.
;This program will define several functions to work with a matrix
;and allow a user to play a game of connect four
;The requirements stated that all functions must begin with the 
;programmer's initials; that is why they all begin with 'abs'.
;Also, the first two sections of functions were required to have
;the same name and purpose, although implementation was up to us.
;We were allowed only one variable (besides parameters), and that
;is the game board (absGame). We were only allowed to import one 
;library, a random number generator
;We were also required to have a unique intro message so that we
;could distinguish our program from other students' programs.
;The goal was to have the best AI, and win the class Connect Four 
;Tournament. My program won.

;Note: this program uses animation, and the pause between the frames
;is determined by the call to absKillTime, in the function absShowGame2.
;To adjust the speed of the animation, change the number in the call.
;The call is at line 741

;When running the program, play proceeds as follows:
;>(what you type)
;--> output

;The following is how a human plays against the program
;>(absStartGame)
;--> > Is the force strong with this one?
;--> #t
;>(absShowGame)
;--> lots of spaces, then a game board
;>(absMarkMove 4) ;4 can be any number 1-7, as the chosen
;                  column for your move
;--> 4  ;absMarkMove and absMakeMove will return the 
;       ;column number that was played so that two
;       ;programs could be played against each other
;>(absShowGame)
;--> lots of spaces, then an animated game board
;>(absMakeMove)
;--> whatever column the AI chose
;>(absShowGame)
;--> lots of spaces, then an animated game board
;the following three commands will loop as follows until
;the conclusion of the game.
;>(absMarkMove <column>)
;>(absShowGame)
;>(absMakeMove)
;>(absShowGame)
;there are some win checking functions, as follows:
;    - (absWinP <column>) will test the current game board to see
;                         if the last move resulted in a win
;    - (absWillWinP <column>) will test the current game board to
;                             see if the given move will result in
;                             a win


;During the tournament, play was as follows, with the class checking
;for wins by eye. Whoever had the better looking game board had
;their display function used. 

;>(aaaStartGame)
;>(bbbStartGame)
;>(aaaShowGame)
;>(bbbShowGame)
;<voting for the better looking board; I'll say that aaa had the
;    better board>
;>(bbbMarkMove (aaaMakeMove)) ;aaa makes a move, and bbb needs to record
;                             ;the fact that the other player moved
;>(aaaShowGame)               ;show the result of the last move
;>(aaaMarkMove (bbbMakeMove)) ;inverse of the last play
;>(aaaShowGame)               ;show the result of the last move
;the last four functions loop until one of the AI's wins





;this is the global variable that will hold the game board
(define absGame '())

;The following is code from program12A.

;absGetCell will return the item at the given grid location 
;in a list of lists
(define (absGetCell matrix row column)
    (absGetColumn (absGetRow matrix row) column)
)

;absGetColumn takes a list and a position and returns the item at
;the given position from the list
(define (absGetColumn input column)
    (if (= column 1)
        (car input)
        (absGetColumn (cdr input) (- column 1))
    )
)

;absGetRow takes a matrix (list of lists) and a position and returns
;the list at the given position
(define (absGetRow input row)
    (if (= row 1)
        (car input)
        (absGetRow (cdr input) (- row 1))
    )
)

;absSetCell takes a matrix and a position and returns a new matrix with
;the given grid location reset to the given value
(define (absSetCell matrix row column item)
    (if (= row 1)
        (cons 
            (absSetColumn (car matrix) column item)
            (cdr matrix)
        )
        (cons 
            (car matrix)
            (absSetCell (cdr matrix) (- row 1) column item)
        )
    )
)

;absSetColumn takes a list, column number, and an item and returns a new
;list with list[column] set to item
(define (absSetColumn input column item)
    (if (= column 1)
        (cons
            item
            (cdr input)
        )
        (cons 
            (car input)
            (absSetColumn (cdr input) (- column 1) item)
        )
    )
)

;this is the beginning of the second part of the program

;the code will be divided into sections:
;    Required Functions,
;    Win Checking Functions,
;    AI Functions,
;    Helper Functions,
;    Various Other Functions, and
;    Display Functions.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section One: Required Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;absStartGame will initialize the game board and display
;a team cheer
(define (absStartGame)
    (begin
	(set! absGame '(
			   (("_")("_")("_")("_")("_")("_")("_"))
			   (("_")("_")("_")("_")("_")("_")("_"))
			   (("_")("_")("_")("_")("_")("_")("_"))
			   (("_")("_")("_")("_")("_")("_")("_"))
			   (("_")("_")("_")("_")("_")("_")("_"))
			   (("_")("_")("_")("_")("_")("_")("_"))
			   ("r") (0)
		       )
	)
	(display "> Is the force strong with this one?\n")
	#t
    )
)

;absMarkMove will make a move specified by the player, and
;return the column number
(define (absMarkMove column)
    (begin
	(set!
	    absGame
	    (absToggle
		(absSetLastTurn
		    (absMarkMove2 absGame column)
		    column
		)
	    )
	)
	column
    )
)

;absShowGame will display the current board state.
;It will call a couple other functions to make the
;board look animated. 
(define (absShowGame)
    (if (= (absGetLastTurn absGame) 0)
	(absShowBoard absGame)
	(absShowGame2
	    absGame
	    (- (absGetTop absGame (absGetLastTurn absGame)) 1)
	    6
	    6
	    (absGetLastTurn absGame)
	    (- 8 (absGetTop absGame (absGetLastTurn absGame)))
	)
    )
)

;absMakeMove will cause a move to be chosen and taken
(define (absMakeMove)
    (absMarkMove
	;absChooseMove works on the main board, and is
	;passed a list of moves that would cause it to lose
	(absChooseMove absGame (absGetLosingMoves absGame))
    )
)

;absLegalMoveP will test a given move to see if it's legal
;with respect to the current game state, and return true 
;or false
(define (absLegalMoveP column)
    (string=? (car (absGetCell absGame 6 column)) "_")
)

;absWinP will test the current game grid to see if the last move
;resulted in a win
(define (absWinP column)
    (absWonP absGame column)
)

;absWillWinP test the current game grid to see if the given
;move will result in a win, and return true or false.
;It will call absWinP's helper function and give it a hypothetical
;game board.
(define (absWillWinP column)
    (absWonP
	(absMarkMove2 absGame column)
	column
    )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section Two: Win Checking Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;absWillWinP2 will be passed a board to act on for the win checking.
;This is basically a copy of absWillWinP, but this version can act
;on a hypothetical board.
(define (absWillWinP2 game column)
    (absWonP
	(absMarkMove2 game column)
	column
    )
)

;absOtherPlayerWin will find out if the other player can win by moving 
;in a certain column
;It makes a hypothetical move in the column, and checks for a win
(define (absOtherPlayerWin game column)
    (absOtherPlayerWin2 (absMarkHypothetical game column) column)
)

;this is a helper function for absOtherPlayerWin
(define (absOtherPlayerWin2 game column)
    (if (null? game)
	#f
	(absWonP
	    game
	    column
	)
    )
)
    
;absWonP is the logic behind finding out if a board contains or
;will contain a win.
;Because it takes a game board as a parameter, it can recieve the
;current state of the board or a hypothetical board. Therefore, it
;can be called by all of the win checking functions.
;It splits the win checking into four directions for clarity.
(define (absWonP game column)
    (or
	(absWinVert      game (- (absGetTop game column) 1) column)
	(absWinHoriz     game (- (absGetTop game column) 1) column)
	(absWinDownDiag  game (- (absGetTop game column) 1) column)
	(absWinUpDiag    game (- (absGetTop game column) 1) column)
    )
)

;absWinVert will return true if there are at least four in a row
;vertically, and false if not.
(define (absWinVert game top column)
    (>=
	(+
	    1
	    (absSumOfLikeColorsDirectional game top column -1 0)
	)
	4
    )
)

;absWinHoriz will return true if there are at least four in a row 
;horizontally, and false if not.
(define (absWinHoriz game top column)
    (>=
	(+
	    1
	    (absSumOfLikeColorsDirectional game top column 0 1)
	    (absSumOfLikeColorsDirectional game top column 0 -1)
	)
	4
    )
)

;absWinDownDiag will return true if there are at least four in a row
;in a downwards diagonal pattern (like \) and false if not.
(define (absWinDownDiag game top column)
    (>= 
	(+
	    1
	    (absSumOfLikeColorsDirectional game top column -1 1)
	    (absSumOfLikeColorsDirectional game top column 1 -1)
	)
	4
    )
)


;absWinUpDiag will return true if there are at least four in a row
;in a upwards diagonal pattern (like /) and false if not.
(define (absWinUpDiag game top column)
    (>= 
	(+
	    1
	    (absSumOfLikeColorsDirectional game top column -1 -1)
	    (absSumOfLikeColorsDirectional game top column 1 1)
	)
	4
    )
)

;absMyNumberOfWins will count the number of ways that a win can be
;made in.
(define (absMyNumberOfWins game)
    (+
	;I use short circuited evaluation here; I check to to make
	;sure that a move is legal before I try to move there
	(if (and (absLegalMovePH game 1) (absWillWinP2 game 1)) 1 0)
	(if (and (absLegalMovePH game 2) (absWillWinP2 game 2)) 1 0)
	(if (and (absLegalMovePH game 3) (absWillWinP2 game 3)) 1 0)
	(if (and (absLegalMovePH game 4) (absWillWinP2 game 4)) 1 0)
	(if (and (absLegalMovePH game 5) (absWillWinP2 game 5)) 1 0)
	(if (and (absLegalMovePH game 6) (absWillWinP2 game 6)) 1 0)
	(if (and (absLegalMovePH game 7) (absWillWinP2 game 7)) 1 0)
    )
)

;absOpponentNumberOfWins will count the number of ways that a win can be
;made in by the opponent
(define (absOpponentNumberOfWins game)
    (+
	;same logic as absMyNumberOfWins, but for the other player
	(if (and (absLegalMovePH game 1) (absOtherPlayerWin game 1)) 1 0)
	(if (and (absLegalMovePH game 2) (absOtherPlayerWin game 2)) 1 0)
	(if (and (absLegalMovePH game 3) (absOtherPlayerWin game 3)) 1 0)
	(if (and (absLegalMovePH game 4) (absOtherPlayerWin game 4)) 1 0)
	(if (and (absLegalMovePH game 5) (absOtherPlayerWin game 5)) 1 0)
	(if (and (absLegalMovePH game 6) (absOtherPlayerWin game 6)) 1 0)
	(if (and (absLegalMovePH game 7) (absOtherPlayerWin game 7)) 1 0)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section Three: AI Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;absChooseMove is the AI for the program. It will decide where the
;best place to move is.
;It passes function calls to a function that will apply the given
;function to each playable (legal) column.
(define (absChooseMove game losingMoves)
    (cond
	;take a win if possible
	((abs1to7 game absWillWinP2 '()) (abs1to7 game absWillWinP2 '()))
	;block a win if possible
	((abs1to7 game absOtherPlayerWin '())
	    (abs1to7 game absOtherPlayerWin '())
	)
	;make three in a row horizontally if possible
	((abs1to7 game absThreeHoriz losingMoves)
	    (abs1to7 game absThreeHoriz losingMoves)
	)
	;block the other player from getting three in a row if possible
	((abs1to7 game absOtherPlayerThreeHoriz losingMoves)
	    (abs1to7 game absOtherPlayerThreeHoriz losingMoves)
	)
	;take a move that will force a win if possible
	((abs1to7 game absCanMakeForcedWin losingMoves)
	    (abs1to7 game absCanMakeForcedWin losingMoves)
	)
	;take a move that will block a forced win if possible
	((abs1to7 game absOtherPlayerForcedWin losingMoves)
	    (abs1to7 game absOtherPlayerForcedWin losingMoves)
	)
	;otherwise, make a move close to the center that doesn't give
	;a win to the opponent
	;I'm passing cons in so that it can actually execute a function
	((abs1to7 game cons losingMoves) (abs1to7 game cons losingMoves))
	;if all else fails, make a move close to the center.
	;At this point, if the last condition failed, it means that any move
	;that the computer makes will result in a loss. This usually
	;happens at the end of a game with perfect playing from both players.
	(#t (abs1to7 game cons '()))
    )
)

;absMarkMove2 will do the logic of marking a move
;this function is useful for making making a hypothetical move
;to see what happens, because it doesn't actually modify the
;game board.
(define (absMarkMove2 game column)
    (if (string=? (absGetTurn game) "r")
	(absSetCell game (absGetTop game column) column '("r"))
	(absSetCell game (absGetTop game column) column '("b"))
    )
)

;absMarkHypothetical will make a hypothetical move for the other player
;if the move is not legal, it will return null
(define (absMarkHypothetical game column)
    (if (absLegalMovePH game column)
	(if (string=? (absGetTurn game) "r")
	    (absSetCell game (absGetTop game column) column '("b"))
	    (absSetCell game (absGetTop game column) column '("r"))
	)
	'()
    )
)

;absMarkMoveFuture will make a series of hypothetical moves
;this function is not currently being used, but it could support
;a minimax tree.
(define (absMarkMoveFuture game moves)
    (if (null? moves)
	game
	(absMarkMoveFuture
	    (absToggle (absMarkMove2 game (car moves)))
	    (cdr moves)
	)
    )
)
;absThreeHoriz will check to see if the computer can make a three in a row
;horizontally for a given column, and return true or false
(define (absThreeHoriz game column)
    (>=
	(+
	    1
	    (absSumOfLikeColorsDirectional
		(absMarkMove2 game column)
		(- (absGetTop (absMarkMove2 game column) column) 1)
		column
		0
		1
	    )
	    (absSumOfLikeColorsDirectional
		(absMarkMove2 game column)
		(- (absGetTop (absMarkMove2 game column) column) 1)
		column
		0
		-1
	    )
	)
	3
    )
)

;absOtherPlayerThreeHoriz will check to see if the other player can make
;three in a row horizontally
(define (absOtherPlayerThreeHoriz game column)
    (>=
	(+
	    1
	    (absSumOfLikeColorsDirectional
		(absMarkHypothetical game column)
		(- (absGetTop (absMarkHypothetical game column) column) 1)
		column
		0
		1
	    )
	    (absSumOfLikeColorsDirectional
		(absMarkHypothetical game column)
		(- (absGetTop (absMarkHypothetical game column) column) 1)
		column
		0
		-1
	    )
	)
	3
    )
    
)

;absCanMakeForcedWin will see if it is possible to force a win
;with a given move
(define (absCanMakeForcedWin game column)
    (< 1 (absMyNumberOfWins (absMarkMove2 game column)))
)

;absCanMakeForcedWin will see if it is possible to force a win
;with a given move
(define (absOtherPlayerForcedWin game column)
    (< 1 (absOpponentNumberOfWins (absMarkHypothetical game column)))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section Four: Helper Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;absLegalMovePH is a version of absLegalMoveP that will be passed
;a board to act on
(define (absLegalMovePH game column)
    (string=? (car (absGetCell game 6 column)) "_")
)

;absGetTop will return the top available spot, or 7 if there are
;no available spots in that column.
(define (absGetTop game column)
    (if (absLegalMovePH game column)
	(absGetTop2 game 1 column)
	7
    )
)

;absGetTop2 will help absGetTop
(define (absGetTop2 game row column)
    (if (string=? (car (absGetCell game row column)) "_")
	row
	(absGetTop2 game (+ row 1) column)
    )
)

;absToggle will take the board and return a board with the 
;player turn switched
(define (absToggle game)
    (if (string=? (absGetTurn game) "r")
	(absSetCell game 7 1 "b")
	(absSetCell game 7 1 "r")
    )
)

;absGetLosingMoves will find moves that will give a win to the other player
(define (absGetLosingMoves game)
    (absGetLosingMoves2 game '(1 2 3 4 5 6 7))
)
;this will help absGetLosingMoves
;it checks each move in the given list, and will return a list of moves
;that should not be taken.
(define (absGetLosingMoves2 game moves)
    ;if all the moves have been tested, return ()
    (if (null? moves)
	'()
	;otherwise, check to see if the current move being tested is legal
	(if (absLegalMovePH game (car moves))
	    ;if the move is legal, check to see if it would allow the
	    ;other player to win
	    (if (absOtherPlayerWin
		    (absMarkMove2 game (car moves))
		    (car moves)
		)
		;if the current move would allow the other player to win,
		;return that move plus the result of checking the rest
		;of the moves
		(cons
		    (car moves)
		    (absGetLosingMoves2 game (cdr moves))
		)
		;otherwise, check the rest of the moves
		(absGetLosingMoves2 game (cdr moves))
	    )
	    ;if the current move is not legal, move on to the next move
	    (absGetLosingMoves2 game (cdr moves))
	)
    )
)

;absHasItem will see if an item is in a list
(define (absHasItem input item)
    (if (null? input)
	#f
	(if (= (car input) item)
	    #t
	    (absHasItem (cdr input) item)
	)
    )
)

;this will output the current player's turn in the given board
(define (absGetTurn game)
    (absGetCell game 7 1)
)

;absGetLastTurn will find out the last turn made in the
;given board
(define (absGetLastTurn game)
    (absGetCell game 8 1)
)

;absSetLastTurn will return a board with the turn field set to the
;column number of the last turn
(define (absSetLastTurn game column)
    (absSetCell game 8 1 column)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section Five: Various Other Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;abs1to7 will try a given function on all spots.
;it will return a spot if the given function returns true,
;and return false if the function returns false on all spots.
(define (abs1to7 game input losingMoves)
    (cond
	;each condition checks to see if
	;    a) the spot is a legal move, and
	;    b) the given function returns true for that spot
	((and (absLegalMovePH game 4)
	     (input game 4)
	     (not (absHasItem losingMoves 4))
	 ) 4)
	((and (absLegalMovePH game 3)
	     (input game 3)
	     (not (absHasItem losingMoves 3))
	 ) 3)
	((and (absLegalMovePH game 5)
	     (input game 5)
	     (not (absHasItem losingMoves 5))
	 ) 5)
	((and (absLegalMovePH game 2)
	     (input game 2)
	     (not (absHasItem losingMoves 2))
	 ) 2)
	((and (absLegalMovePH game 6)
	     (input game 6)
	     (not (absHasItem losingMoves 6))
	 ) 6)
	((and (absLegalMovePH game 1)
	     (input game 1)
	     (not (absHasItem losingMoves 1))
	 ) 1)
	((and (absLegalMovePH game 7)
	     (input game 7)
	     (not (absHasItem losingMoves 7))
	 ) 7)
	(#t #f)
    )
)


;this is the actual checker for the win conditions. It will take 
;a board, the top chip (the last move or a hypothetical move), the
;column the move was made in, the change in y, and the change in x.
;The change in y and x signify if the function is checking up, down,
;left, right, or any legal combination of those directions.
;It returns the sum of chips in the specified direction.
;It will return one less than the actual number, because it will not
;count the starting chip.
(define (absSumOfLikeColorsDirectional game row column dy dx)
    ;this checks to see if the current or next position (column, row)
    ;is illegal, if the current cell is empty, or if the next cell is
    ;not equal to the current cell. If any of those are true, then the
    ;function will return 0. If none of those were true, it will return
    ;1 + the directional sum of the next cell.
    (if (or
	    ;these make sure that the current spot is in range
	    (< column 1)
	    (> column 7)
	    (< row 1)
	    (> row 6)
	    ;these make sure the next spot is in range
	    (< (+ column dx) 1)
	    (> (+ column dx) 7)
	    (< (+ row dy) 1)
	    (> (+ row dy) 6)
	    ;see if the current cell is empty
	    (string=? (car (absGetCell game row column)) "_")
	    ;see if the next cell is different than the current one
	    (not (string=? 
		     (car (absGetCell game row column))
		     (car (absGetCell game (+ row dy) (+ column dx)))
		 )
	    )
	)
	;if any of the above conditions were true, return 0
	0
	;otherwise, return 1 + the directional sum of the next cell
	(+ 1 (absSumOfLikeColorsDirectional
		 game
		 (+ row dy)
		 (+ column dx)
		 dy
		 dx
	     )
	)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section Six: Display Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;absShowGame2 will display the board in a way that makes it look animated.
(define (absShowGame2 game topPiece currentRow workRow column iteration)
    ;iteration starts out at the maximum number of times that this function
    ;can call itself, and decreases each recursive call.
    (if (> iteration 0)
	(begin
	    ;show a generated board
	    (absShowBoard
		(absGenerateBoard
		    game
		    topPiece
		    currentRow
		    workRow
		    column
		)
	    )
	    ;pause for a moment
	    (absKillTime 10000000)
	    ;do a recursive call
	    (absShowGame2
		game
		topPiece
		(- currentRow 1)
		(- workRow 1)
		column
		(- iteration 1)
	    )
	)
	#t
    )
)
;absGenerateBoard will create one board in a series of boards displayed
;in the style of a flipbook
(define (absGenerateBoard game topPiece currentRow workRow column)
    (absSetCell
	(absSetCell
	    game
	    topPiece
	    column
	    '("_")
	)
	(if (< workRow topPiece)
	    topPiece
	    workRow; this is the row that has the 
	)          ; "falling" piece
	column
	(if (string=? (absGetTurn game) "r")
	    '("b")
	    '("r")
	)
    )
)
;absShowBoard does the output for the game.
(define (absShowBoard game)
    (begin
	(newline) (newline) (newline) (newline) (newline)
	(newline) (newline) (newline) (newline) (newline)
	(newline) (newline) (newline) (newline) (newline)
	(display "   ")
	(display (absGetRow game 6)) (newline)
	(display "   ")
	(display (absGetRow game 5)) (newline)
	(display "   ")
	(display (absGetRow game 4)) (newline)
	(display "   ")
	(display (absGetRow game 3)) (newline)
	(display "   ")
 	(display (absGetRow game 2)) (newline)
	(display "   ")
	(display (absGetRow game 1)) (newline)
	(display "   |===========================|") (newline)
	(display "   |                           |") (newline)
	(display "   |                           |") (newline)
	(display "  / \\                         / \\") (newline)
	(display " /   \\                       /   \\") (newline)
        #t
    )
)

;absKilltime will create a short delay in the program execution
;for a short delay, (absKilltime 1000000)
(define (absKillTime n)
    (if (= n 0)
	n
	(absKillTime (- n 1))
    )
)
