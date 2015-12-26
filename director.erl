-module(director).
-export([new_play/1]).

string_contains(Big, Small) ->
    string:str(Big, Small) > 0.
find_play(PlayName) ->
    PlayName.
new_play(PlayName) ->
    case file:open(find_play(PlayName), [read]) of
        {ok, File}->
            io:format('Starting ~w~n' [PlayName])
            director(File, []);
        {error, Reason} ->
            io:format('Shakespeare refused to write ~w for whatever ~w ~n',[PlayName, Reason])
    end.

director(File, ActorList) ->
linetype(Line) ->
    if
        string_contains(Line, "<h3>") ->
            {title, Line};
        string_contains(Line,"<a") ->
            if
                string_contains(Line,"<b>") ->
                    {actor, Line};
                true ->
                    {dialog, Line}
            end;
        string_contains(Line,"<i>") ->
            {direction, Line};
        true ->
            extra
    end.





reader(File, ActorList) ->
    case

    % 1. line has actor

    % 2. line has dialog
    % 3. line has action
find_actor(Name) ->
new_actor(Name, DirectorPid) ->
    spawn(actor, actor, [Name, DirectorPid]).
