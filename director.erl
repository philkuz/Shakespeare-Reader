-module(director).
-export([current_actors/0, start/0, find_play/1]).

string_contains(Big, Small) ->
    string:str(Big, Small) > 0.


find_play(PlayName) ->
    % PlayName.
    case length(string:tokens(PlayName, ".")) of
        1 ->
            string:concat(PlayName,".html");
        2 ->
            PlayName
    end.


current_actors() ->
    current_actors(#{"current" => ""}).

current_actors(Actors) ->
    receive
        {add, Actor} ->
            PiD = spawn(actor, actor,[Actor]),
            New_Actors = maps:put(Actor, PiD, Actors),
            current_actors(New_Actors);
        {speak, Message} ->
            give_dialog(Message, Actors),
            current_actors(Actors);
        {set, Actor} ->
            case maps:get(Actor, Actors, failed) of
                failed ->
                    Pid = spawn(actor, new_actor, [Actor]),
                    New_Actors = maps:update("current", Pid, maps:put(Actor, Pid, Actors)),
                    current_actors(New_Actors);
                ActorPid ->
                    New_Actors = maps:update("current", ActorPid, Actors),
                    current_actors(New_Actors)
            end
    end.


give_dialog(Dialog, Actors) ->
    case maps:get("current", Actors,"") of
        "" ->
            yes;
        Actor_Pid ->
            Actor_Pid ! {line, Dialog}
    end.


new_play(PlayName) ->
    case file:open(find_play(PlayName), [read]) of
        {ok, File}->
            io:format("Starting ~p~n", [PlayName]),
            reader(File);
        {error, Reason} ->
            io:format('Shakespeare refused to write ~p for whatever ~p ~n',[PlayName, Reason])
    end.


% takes the html line that contains a title and returns the title.
filter_tag(Line, Tags) ->
    [Tag1, Tag2| _] = Tags,
    Left = string:str(Line, Tag1) + string:len(Tag1),
    Right = string:str(Line, Tag2) - 1,
    string:sub_string(Line,Left,Right).

actor_dialog(Line) ->
    case string_contains(Line,"<a") of
        true ->
            case string_contains(Line,"<b>") of
                true -> 0;
                false -> 1
            end;
        false -> false
    end.
find_type(Line) ->
    find_type(Line, ["<h3>","<i>"], 2).
find_type(Line, [], N) ->
    case actor_dialog(Line) of
        false ->
            N;
        Other ->
            Other
    end;
find_type(Line, Substr, N) ->
    [Marker|Rest] = Substr,
    case string_contains(Line,Marker) of
        true ->
            find_type(Line, [], N);
        false ->
            find_type(Line, Rest, N+1)
    end.

interpret_line(Line) ->
    case find_type(Line) of
        0 ->
            {actor, filter_tag(Line,["<b>","</b>"])};
        1 ->
            {dialog, filter_tag(Line, [">","</"])};
        2 ->
            {title, filter_tag(Line,["<h3>","</h3>"])};
        3 ->
            {direction, filter_tag(Line,["<i>","</i>"])};
        4 ->
            format
    end.
director(Line) ->
    case interpret_line(Line) of
        {actor, Actor} ->
            actors ! {set, Actor};
        {dialog, Dialog} ->
            actors ! {speak, Dialog};
        {title, Title} ->
            io:format("~p~n", [Title]);
        {direction, Direction} ->
            io:format("      ~p~n",[Direction]);
        format -> ok
    end.
reader(File) ->
    case file:read_line(File) of
        {ok, Line} ->
            director(Line),
            timer:sleep(100),
            reader(File);
        {error, Message} ->
            io:format("~p~n",[Message]);
        eof ->
            io:format("Fin~n",[])
    end.

start() ->
    Director = spawn(director, current_actors, []),
    register(actors, Director),
    new_play("hamlet").
