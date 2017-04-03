-module(baggins).

-export([start/1]).

-export([tick_function/3]).

-export([init/1]).

start(State)->
    mas:start(baggins,State).


init(#{name := Name, hunger := Hunger}) ->
    Agent=#{name => Name, hunger => Hunger},
    SP=[],
    {Agent,SP}.

tick_function(_,Agent,_)->

    {Agent,true}.
