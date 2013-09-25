-module (erly_ad_hoc_upload_manager).
-export ([process_request/1]).

-record(state, {filename, file}).

process_request(Req)->
    Callback = fun(N) -> upload_callback(N, #state{}) end,
    io:format("~nprocess_request~n", []),
    mochiweb_multipart:parse_multipart_request(Req, Callback),
    <<"OK">>.




upload_callback(Next, State) ->
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
            fun(N) -> upload_callback(N, NewState) end;
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
            fun(N) -> upload_callback(N, NewState) end;
         body_end ->
            if State#state.file =/= undefined ->
                file:close(State#state.file);
            true ->
                ok
            end,
            fun(N) -> upload_callback(N, #state{}) end;
         _ ->
            fun(N) -> upload_callback(N, State) end
    end.