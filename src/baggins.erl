-module(baggins).

-export([start/1]).

-export([tick_function/3,get_name/1]).

%% Testing
-export([sample/0]).

-export([init/1]).

start(State)->
    mas:start(baggins,State).


init(#{name := Name, hunger := Hunger}) ->
    Agent= #{ name   => Name,
	      hunger => Hunger},
    SP = [],
    {Agent,SP}.

%% Decreases hunger each round
tick_function(Data,Agent,_)-> % {Agent,Alive}
    A2=map_on(Data,Agent,
	   fun(L)-> {F,_}=L,F end,
	   fun(L)-> {_,D}=L,D end),
    {A2,true}.


map_on([],Agent,_,_)->Agent;
map_on([F|R],Agent,Destr_Fun,Destr_Data)->
    A2=(Destr_Fun(F))(Agent,Destr_Data(F)),
    map_on(R,A2,Destr_Fun,Destr_Data).

%% Sample Functions
sample()->
    S = baggins:start(#{name => frodo,hunger => 100}),
    mas:tick(S,[{fun effect_hunger/2, #{hunger => -rand:uniform(5)}}]),
    mas:tick(S,[{fun effect_hunger/2, #{hunger => -50}}]),
    mas:tick(S,[{fun effect_hunger/2, #{hunger => -rand:uniform(5)}}]),
    get_name(S).


effect_hunger(Agent,#{hunger := Hunger})->
    Agent#{hunger := Hunger + get_hunger(Agent)}.

get_hunger(#{hunger := Hunger})->
    Hunger.

get_name(PID_A)->
    mas:get(PID_A,
	    fun(#{hunger := Name})->
		    Name
	    end).

req_name(PID_A,PID_B)->
    mas:req(PID_A,
	    fun(#{name := Name})->
		    Name
	    end).
