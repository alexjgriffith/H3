-module(bagins).

-export([process_running_p/1,check/1,tick/1,kill/1,bagins_bot/2, new_agent/1,agent_ask_name/3,start/2,agent_greeting/3,agent_print_val/2,agent_get_hunger/1]).

-import(hobnames,[hobbit_name/0]).

-import(sync,[sync_ticks/3]).

-import(timer,[apply_after/4]).

bagins_bot(Agent,SP)->
    receive
	{get,Get_Fun}->
	    Get_Fun(Agent),
	    bagins_bot(Agent,SP);
	{req,Env_PID,Req_Function,Data}->
	    Env_PID ! Req_Function(Data,Agent,SP),
	    bagins_bot(Agent,SP);
	{resp,Env_PID,Res_Function,Data} ->
	    Env_PID ! Res_Function(Data,Agent,SP),
	    bagins_bot(Agent,SP);
	{tick,Tick_PID,Tick_Function, Data}  ->
	    A2 = Tick_Function(Data,Agent,SP),
	    case agent_alive(A2) of
		true ->
		    Tick_PID ! {alive,self()},
		    bagins_bot(A2,SP);
		false ->
		    Tick_PID ! {dead,agent_get_name(Agent)}
	    end
    end.

new_agent(Name)->
    #{name => Name, hunger => 100, alive => true}.

agent_greeting(TheirName,#{name := MyName},_)->
    io:format("Hello ~w, my name is ~w.~n",[TheirName,MyName]).

agent_ask_name(_,#{name := Name},_)->
    io:format("My name is ~w.~n",[Name]),
    {resp,self(),fun bagins:agent_greeting/3,Name}.

agent_get_name(#{name := Name})->
    Name.

agent_get_hunger(#{hunger := Hunger})->
    Hunger.

%% agent_print_val("Hunger is ~w.~n",fun agent_get_hunger/1)
agent_print_val(Str,Func)->
    fun(Agent)->
	    io:format(Str,[Func(Agent)])
    end.

agent_check_dead(_,#{hunger := Hunger},_)->
    (Hunger =< 0).

agent_decrease_hunger(#{hunger := Hunger},Agent,_)->
    PrevHunger = agent_get_hunger(Agent),
    Agent#{
      hunger := PrevHunger + Hunger
     }.

agent_tick_function(Data,Agent,SP)->
    A2 = agent_decrease_hunger(Data,Agent,SP),
    %% Check if the agent has died
    case agent_check_dead(Data,A2,SP) of
	true -> agent_make_dead(A2);
	false -> A2
    end.


agent_make_dead(Agent)->
    Agent#{
      alive := false
     }.

agent_alive(#{alive := Life})->
    Life.


kill([])->
 io:format("Processes Ended ~n",[]);
kill([T|R]) ->
    T ! finished,
    kill(R).

tick_fun(T)->
    case process_running_p(T) of
	true ->
	    T ! {tick,self(), fun agent_tick_function/3,#{hunger => -1 * (rand:uniform(3)+1)}},
	    %%io:format("Agent is alive.~n",[]),
	    true;
	false ->
	    io:format("Agent has died.~n",[]),
	    false
    end.


tick([])-> [];
tick([T|R]) ->
    case process_running_p(T) of
	true ->
	    T ! {tick,self(), fun agent_tick_function/3,#{hunger => -1 * (rand:uniform(3)+1)}},
	    receive
		{alive, _}->
		    %%io:format("Agent ~w is alive.~n",[Name]);
		    true ;
		{dead, Name} ->
		    io:format("Agent ~w has died.~n",[Name]),
		    false
	    end;
	false -> false %io:format("Agent is dead.~n",[])
    end,
    tick(R).

ticks(0,_)->
    [];
ticks(N,L) ->
    tick(L),
    check(L),
    ticks(N-1,L).


spawn_cohort(0,RET)->
    RET;
spawn_cohort(N,RET)->
    spawn_cohort(N-1,RET ++ [spawn(bagins,bagins_bot,[new_agent(hobbit_name()),[]])]).

process_running_p(PID)->
    %% {_,State} = lists:nth(3,process_info(PID)),
    %% io:format("State = ~w ~n",[State]),
    %% (State == runnable) or (State == runing) or (State == waiting)
	is_list(process_info(PID)).

check([])-> [];
check([F|R])->
    F ! {get,agent_print_val("Hunger is ~w.~n",fun agent_get_hunger/1)},
    check(R).


start(N,M)->
    Cohort = spawn_cohort(N,[]),
    sync_ticks(M,Cohort,fun tick_fun/1,kill).
