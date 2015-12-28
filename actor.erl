-module(actor).
-compile([actor/1]).

actor(Name) ->
    io:format("Actor ~w created~n",[Name]),
    receive
        {line, Line} ->
            io:format("~p: ~p~n", [Name, Line]),
            actor(Name);
        Tine ->
            io:format("~p: ~p~n", [Name, Tine])
    end.
