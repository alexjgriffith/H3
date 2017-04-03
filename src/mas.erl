-module(mas).

-export([entity/2]).

entity (Agent,SP)->
    receive
	{get,Get_Fun}->
	    Get_Fun(Agent),
	    entity(Agent,SP);
	{req,Req_Function,Data}->
	    A2 = Req_Function(Data,Agent,SP),
	    entity(A2,SP);
	{tick,Tick_Function,Data}  ->
	    {A2,Alive} = Tick_Function(Data,Agent,SP),
	    case Alive of
		true ->
		    bagins_bot(A2,SP);
		false ->
		    false
	    end
    end.
