:- use_module(library(sweet), except([in/2])).
:- op(200, fy, (#)).

:- use ansi_term.
:- use bencode.
:- use clpfd.
:- use func.
:- use julian.
:- use list_util.
:- use spawn.
:- use tty.
:- use www_browser.


:- discontiguous slide/1.
:- dynamic baz/1, hello/1.
:- guitracer.


go :-
    once(clause(slide(Name),_)),
    go(Name).


go(Start) :-
    nb_setval(previous_slide,no_previous_slide),
    bagof(Name, Body^clause(slide(Name),Body), Names),
    drop_while(\=(Start), Names, Slides),
    member(Slide,Slides),
    nb_setval(previous_slide, Slide),
    slide(Slide).


resume :-
    nb_getval(previous_slide,Slide),
    Slide \= none,
    go(Slide).


slide(cover) :-
    # "Production Prolog".


% bio and company intro
slide(me) :-
    # "mndrix".
slide(us) :-
    # "PriceCharting: Video Game Prices".
slide(vgpc) :-
    url("http://videogames.pricecharting.com/game/super-nintendo/chrono-trigger").
slide(langs) :-
    # "Perl, JavaScript, Haskell, Go".
slide(and_prolog) :-
    # "... and Prolog since March 2013".


% language intro
slide(history) :-
    # "History".
slide(logic) :-
    # "First-order logic".
slide(colmerauer) :-
    % same year as Smalltalk, C
    # "Alain Colmerauer, 1972".
slide(implementations) :-
    % we use SWI-Prolog
    # "Many solid implementations".
slide(ridiculous) :-
    % only and, or, unification, term rewriting
    % no loops
    % no conditionals
    % no mutable state
    # "Ridiculously simple".
slide(repl_demo) :-
    # "Demo: top-level".

% demo: top-level, basic language features
%     A=foo.                  % variable vs atom
%     A=foo, A=bar.           % immutable
%     foo(a,Y)=foo(X,b).      % goes both ways
%     (X=a;foo(X)=foo(7)).    % backtracking
%     (X=a;foo(X)=foo(7)),
%         integer(X).
%     listing(baz).           % program is a database
%         baz(X).
%         assert(baz(4.0)).
%         baz(X).
%     describe append/3 relation
%         append([a],[b,c],L).
%         append(F,[b,c],[a,b,c]).
%         append([a],B,[a,b,c]).
%         append(F,B,[a,b,c]).
%     listing(append/3).
baz(1).
baz(X) :-
    member(X, [two,three]).


% aside to describe backtracking
slide(backtrack) :-
    # "Backtracking".
slide(backtrack_video) :-
    url("http://youtu.be/E6OcNfX7_BM?t=1m47s").


% homoiconicity
slide(homoiconic) :-
    # "Homoiconic: It's all terms".
slide(whats_this) :-
    # "Demo: writeln(hello)".
% simple example
% X = writeln(hello).
% $X = writeln(What).
% write($X).
% call($X).
%
% closures
% plus(1,2,N).
% maplist(plus(1),[1,2,3],L).
% X=1, maplist(plus(X), [1,2,3],L).
% G = maplist(plus(X),[1,2,3],L), X=4, call(G).
%
% reversible maplist
% maplist(plus(X),[1,2,3],[2,3,4]).


% development tools
slide(swi) :-
    # "SWI-Prolog".
slide(debugger) :-
    # "Demo: debugger and backtracking".

short(Atom) :-
    atom_codes(Atom, Codes),
    len(Codes, Len),
    Len < 4.

%len([], 0).
len([_|T],N) :-
    len(T,N0),
    succ(N0,N).

slide(debugger_reprise) :-
    # "Demo: debugger and backtracking".


% development tools, continued
slide(mercury) :-
    # "Mercury: bisecting debugger".
slide(gxref) :-
    # "Code is data therefore tools".
% code navigator
% gxref/0.
% check/0.


% func pack
slide(packs) :-
    # "pack_install(foo)".
slide(func) :-
    % describe variables everywhere
    # "library(func)".
slide(intermediate_variables) :-
    % short/1 has too many names
    # "Naming things is hard".
slide(macros) :-
    # "N = length $ atom_codes $ hi".


slide(mavis) :-
    # "library(mavis)".
slide(optional_types) :-
    # "optional type declarations".
slide(types_are_predicates) :-
    % like Turing complete, dependent types
    # "types are predicates".


slide(reversible) :-
    # "Reversible predicates".
slide(bencode) :-
    # "Demo: library(bencode)".
% bencode(hello, X).
% bencode(X, `5:hello`).
slide(coroutines) :-
    # "coroutines and laziness".


slide(clpfd) :-
    # "Constraint Logic Programming".
slide(julian) :-
    # "Demo: library(julian)".
% form_time(now, Dt).
% form_time(unix(E), $Dt).
% form_time(dow(friday), $Dt).
% form_time(dow(Day), $Dt).
% remember ... just constraints
% Year in 1953..1961,
%     form_time([dow(sunday), Year-07-04]).


slide(concurrency) :-
    % SWI-Prolog has good support for native threads
    % threads communicate through channels
    # "Concurrency".
slide(spawn) :-
    # "Demo: library(spawn)".


attendee(mndrix, person(michael, hendricks)) :-
    sleep(2).

session(production_prolog, session(thursday,centene)) :-
    sleep(2).

first_name(person(F,_),F).
room(session(_,R),R).

slow :-
    attendee(mndrix, Person),
    session(production_prolog, Session),

    first_name(Person, FirstName),
    room(Session, Room),
    format("Hi ~s. Go to room ~s~n", [FirstName, Room]).
% time(slow).
% edit(slow).
% time(slow).
% remember: not part of the language, just a library


slide(saved_state) :-
    % parse, compile, bundle all dependencies
    % single file for deployment
    # "Deploying Saved States".
slide(swipl_compile) :-
    # "swipl -o foo -c foo.pl".


slide(rainbows) :-
    # "Not all Sunshine and Rainbows".
slide(nit_syntax) :-
    # "syntax vs git".
slide(nit_ecosystem) :-
    % too few static analysis tools
    % slightly weak support in editors
    # "small ecosystem".
slide(nit_curve) :-
    % very different way of thinking about software
    # "learning curve".
slide(nit_failure) :-
    # "failure is hard to debug".
slide(nit_macros) :-
    # "macros are hard to debug".
slide(nit_performance) :-
    # "occasional performance issues".



% all done
slide(end) :-
    tty_clear,
    tty_size(Rows,_),
    TopSpace is floor(Rows * 0.4),
    forall(between(1,TopSpace,_),nl),
    format("?- the_end.~n").

#(Message) :-
    tty_clear,
    tty_size(Rows, Cols),

    % white space at the top
    TopSpace is floor((Rows-2)/2),
    n(TopSpace, nl),

    % the message itself
    string_length(Message, N),
    SpaceCount is floor((Cols - N) / 2),
    n(SpaceCount, write(" ")),
    ansi_format([], Message, []),
    nl,

    % white space at the bottom (pushing "true" downwards)
    BottomSpace is Rows - TopSpace - 2,
    n(BottomSpace,nl).

url(Url) :-
    # "",
    www_open_url(Url).

:- meta_predicate n(+,0).
n(N, Goal) :-
    forall(between(1,N,_),Goal).
