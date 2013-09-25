%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc Web server for erly_ad_hoc.

-module(erly_ad_hoc_web).
-author("Mochi Media <dev@mochimedia.com>").

-export([start/1, stop/0, loop/2]).

-record(state, {filename, file}).

callback(Next, State) ->
    case Next of
        {headers, Headers} ->
            % Find out if it is a file
            [ContentDisposition|_] = Headers,
            NewState = case ContentDisposition of
                {"content-disposition", {"form-data",[{"name",_},
                    {"filename",Filename}]}} ->
                    #state{filename="priv/tmp/"++Filename};
                _ ->
                    State
            end,
            fun(N) -> callback(N, NewState) end;
        {body, Data} ->
            if  State#state.filename =/= undefined ->
                if State#state.file =/= undefined ->
                    file:write(State#state.file, Data),
                    NewState = State;
                true ->
                    case file:open(State#state.filename, [raw,write]) of
                        {ok, File} ->
                            file:write(File, Data),
                            NewState = State#state{file=File};
                        {error, Error} ->
                            io:format(
                                "Couldn't open ~p for writing, error: ~p~n",
                                [State#state.filename, Error]),
                            NewState=State,
                            exit(could_not_open_file_for_writing)
                    end
                end;
            true ->
                NewState = State
            end,
            fun(N) -> callback(N, NewState) end;
         body_end ->
            if State#state.file =/= undefined ->
                file:close(State#state.file);
            true ->
                ok
            end,
            fun(N) -> callback(N, #state{}) end;
         _ ->
            fun(N) -> callback(N, State) end
    end.


%% External API

start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req, DocRoot) ->
    "/" ++ Path = Req:get(path),
    try
        case Req:get(method) of
            Method when Method =:= 'GET'; Method =:= 'HEAD' ->
                case Path of
                    _ ->
                        Req:serve_file(Path, DocRoot)
                end;
            'POST' ->
                case Path of
                    "upload" ->
                      Callback = fun(N) -> callback(N, #state{}) end,
        mochiweb_multipart:parse_multipart_request(Req, Callback),
        Req:ok({"text/html", [], <<"<html><body><h1>File Upload</h1>
<p>Uploaded successfully.</p>
</body></html>">>});
                    _ ->
                        Req:not_found()
                end;
            _ ->
                Req:respond({501, [], []})
        end
    catch
        Type:What ->
            Report = ["web request failed",
                      {path, Path},
                      {type, Type}, {what, What},
                      {trace, erlang:get_stacktrace()}],
            error_logger:error_report(Report),
            %% NOTE: mustache templates need \ because they are not awesome.
            Req:respond({500, [{"Content-Type", "text/plain"}],
                         "request failed, sorry\n"})
    end.

%% Internal API

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.

%%
%% Tests
%%
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

you_should_write_a_test() ->
    ?assertEqual(
       "No, but I will!",
       "Have you written any tests?"),
    ok.

-endif.
