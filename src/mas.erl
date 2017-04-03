-module(mas).

-export([start/2]).

-export([tick/2,get/2,req/3.]).
-export([init/2]).

start(Mod,State)->
    spawn(mas,init,[Mod,State]).

init(Mod,State)->
    register(Mod,self()),
    {Agent,SP} = Mod:init(State),
    loop(Agent,SP,Mod).

tick(PID_Agent,Data) ->
    PID_Agent ! {tick, Data}.

get (PID_Agent,Get_Fun) ->
    PID_Agent ! {get,self(), Get_Fun},
    receive
	{response,Results}->
	    Results
    end.

req (PID_Agent,Req_Function,Data) ->
    PID_Agent ! {req,Req_Function, Data}.

loop (Agent,SP,Mod)->
    receive
	{get,PID,Get_Fun}->
	    PID ! {response, Get_Fun(Agent)},
	    loop(Agent,SP,Mod);
	{req,Req_Function,Data}->
	    A2 = Req_Function(Data,Agent,SP),
	    loop(A2,SP,Mod);
	{tick,Data}  ->
	    {A2,Alive} = Mod:tick_function(Data,Agent,SP),
	    case Alive of
		true ->
		    loop(A2,SP,Mod);
		false ->
		    false
	    end
    end.
