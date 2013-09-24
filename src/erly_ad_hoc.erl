%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc erly_ad_hoc.

-module(erly_ad_hoc).
-author("Mochi Media <dev@mochimedia.com>").
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.


%% @spec start() -> ok
%% @doc Start the erly_ad_hoc server.
start() ->
    erly_ad_hoc_deps:ensure(),
    ensure_started(crypto),
    application:start(erly_ad_hoc).


%% @spec stop() -> ok
%% @doc Stop the erly_ad_hoc server.
stop() ->
    application:stop(erly_ad_hoc).
