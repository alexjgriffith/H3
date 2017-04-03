-module(sync).

-export([sync_ticks/3]).


broadcast([],_)->
    [];
broadcast([T|R],Broad_Fun) ->
    Broad_Fun(T),
    broadcast(R,Broad_Fun).

sync_tick(aux,0,Alive)-> Alive;
sync_tick(aux,N,Alive)->
    receive
	{alive,PID}->
	    sync_tick(aux,N - 1,Alive ++ [PID]);
	{dead,_} ->
	    sync_tick(aux,N - 1,Alive)
    end.

sync_tick(L,Broad_Fun)->
    broadcast(L,Broad_Fun),
    Alive = sync_tick(aux,length(L),[]),
    Alive.

sync_ticks(0,_,_)->[];
sync_ticks(N,Pids,Broad_Fun)->
    sync_ticks(N - 1,sync_tick(Pids,Broad_Fun),Broad_Fun).
