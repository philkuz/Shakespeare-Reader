-module(actor).
-export([new_actor/1]).

new_actor(Name) ->
    receive
        {line, Line} ->
            io:format("   ~p: ~p~n", [Name, Line]),
            new_actor(Name)
    end.
