:- consult('io.pl').
:- consult('logic.pl').


%start.

start:-
  welcome_message,
  main_menu.


%main_menu.

main_menu :-
  repeat,
  format('What would you like to do?~n1 - Play.~n2 - Change gamemode.~n3 - Change board size.~n4 - leave.~n', []),
  read_line(Codes),
  catch(number_codes(Option, Codes),_, fail),
  Option > 0,
  Option < 5,
  (
    Option =:= 4;
    main_menu(Option),
    fail
  ).

main_menu(1):- play.
main_menu(2):- get_gamemode.
main_menu(3):- get_boardsize.

%play.
play:-
  size(Size),
  initial_state(Size, Gamestate),
  display_game(Gamestate).

%board functions


:- dynamic board/2.
%board(?B)
board([
  [1,1,0,0],
  [0,2,0,0],
  [0,2,1,0],
  [0,0,1,0]],4).

%get_position(+Row,+Col,?N)
get_position(Row,Col,N):-
  Row >=0,
  Row <4,
  Col >=0,
  Col <4,
  board(B,_),
  get_position_aux(Row,Col,B,N).

get_position_aux(0,0,[[H|_]|_],H).
get_position_aux(0,Col,[[_|T]|_],N):-
  Col1 is Col -1,
  get_position_aux(0,Col1,[T|_],N).
get_position_aux(Row,Col,[_|T],N):-
  Row1 is  Row-1,
  get_position_aux(Row1,Col,T,N).

%print_board
print_board:-
  board([A,B,C,D],_),
  print_line(A),
  print_line(B),
  print_line(C),
  print_line(D).

print_line([A,B,C,D]):-
  print(A),
  print(B),
  print(C),
  print(D),
  print('\n').

%is_empty(+Row,+Col)
is_empty(Row,Col):-
  get_position(Row,Col,N),
  !,
  N is 0.

%move functions

%put_piece(+C,+Row,+Col)
put_piece(C,Row,Col):-
  is_empty(Row,Col),
  board(B,N),
  retract(board(B,N)),
  replace(B,Row,Col,C,B2),
  assert(board(B2,N)).

replace([[_|T]|Tail],0,0,C,[[C|T]|Tail]).
replace([[H|T]|Tail],0,Col,C,[[H|T2]|Tail2]):-
  Col1 is Col -1,
  replace([T|Tail],0,Col1,C,[T2|Tail2]).
replace([H|T],Row,Col,C,[H|T2]):-
  Row1 is Row -1,
  replace(T,Row1,Col,C,T2).

%move_piece(+C,+Row,+Col,+Row2,+Col2)
move_piece(C,Row,Col,Row2,Col2):-
  distance(Row,Row2),
  distance(Col,Col2),
  is_empty(Row2,Col2),
  get_position(Row,Col,Num),
  !,
  Num is C,
  board(B,N),
  retract(board(B,N)),
  replace(B,Row,Col,0,B2),
  replace(B2,Row2,Col2,C,B3),
  assert(board(B3,N)).

distance(N1,N2):-
  N1 is N2.
distance(N1,N2):-
  N1 is N2 -1.
distance(N1,N2):-
  N1 is N2 +1.

%eat_piece(+C,+Row,+Col,+Row2,+Col2)
eat_piece(C,Row,Col,Row2,Col2):-
  check_pieces(Row,Col,Row2,Col2,Row3,Col3),
  get_position(Row,Col,Num1),
  !,
  Num1 is C,
  get_position(Row2,Col2,Num2),
  !,
  \+ Num1 is Num2,
  board(B,N),
  retract(board(B,N)),
  replace(B,Row,Col,0,B2),
  replace(B2,Row2,Col2,0,B3),
  replace(B3,Row3,Col3,C,B4),
  assert(board(B4,N)).
  

check_pieces(Row,Col,Row2,Col2,Row3,Col3):-
  Row is Row2 +1,
  Col is Col2 +1,
  Row3 is Row2 -1,
  Col3 is Col2 -1.
check_pieces(Row,Col,Row2,Col2,Row3,Col3):-
  Row is Row2 -1,
  Col is Col2 -1,
  Row3 is Row2 +1,
  Col3 is Col2 +1.
check_pieces(Row,Col,Row2,Col2,Row3,Col3):-
  Row is Row2 +1,
  Col is Col2 -1,
  Row3 is Row2 -1,
  Col3 is Col2 +1.
check_pieces(Row,Col,Row2,Col2,Row3,Col3):-
  Row is Row2 -1,
  Col is Col2 +1,
  Row3 is Row2 +1,
  Col3 is Col2 -1.