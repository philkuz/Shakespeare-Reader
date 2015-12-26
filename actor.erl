-module(actor).
-compile([actor/1]).

actor(Name, DirectorPid) ->
    receive
        {line, Line} ->
            io:format("~w: ~w", [Name, Line]),
            DirectorPid ! done,
            actor(Name, DirectorPid);
    end.
