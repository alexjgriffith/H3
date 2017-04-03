-module(hobnames).

-export([hobbit_name/0]).

sum_odds([],Ret,_)->
    Ret;
sum_odds([F|R],Ret,Destructure) ->
    N=Destructure(F),
    sum_odds(R,Ret+N,Destructure).

sum_odds(L,Destructure)->
    sum_odds(L,0,Destructure).


odds_to_ranges(L,Destructure)->
    Odds = sum_odds(L,Destructure),
    odds_to_ranges(0,L,Odds,[],Destructure).

odds_to_ranges(_,[],_,Ranges,_)->
    Ranges;
odds_to_ranges(S,[E|R],Odds,Ranges,Destructure)->
    Ep =Destructure(E),
    N={S/Odds,(S+Ep)/Odds},
    odds_to_ranges(S+Ep,R,Odds,Ranges ++ [N], Destructure).

rand_select([],[],_)->
    error("Outside of range");
rand_select([FN|RN],[FR|RR],Rand) ->
    {A,B}=FR,
    {Name,_}=FN,
    if
	(Rand >= A) and (Rand<B)->
	    Name;
	true ->
	    rand_select(RN,RR,Rand)
    end.

rand_select(List,Ranges)->
    rand_select(List,Ranges,rand:uniform()).

hobbit_name()->
    Names = [{bilbo,1},
	     {frodo,1},
	     {samwise,1},
	     {perigrin,1},
	     {meriadoc,1},
	     {sandyman,1},
	     {tillson,1}],
    rand_select(Names,
		odds_to_ranges(Names,fun(F)-> {_,N}=F,N end)).
