%% @author Mochi Media <dev@mochimedia.com>
%% @copyright erly_ad_hoc Mochi Media <dev@mochimedia.com>

%% @doc Callbacks for the erly_ad_hoc application.

-module(erly_ad_hoc_app).
-author("Mochi Media <dev@mochimedia.com>").

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for erly_ad_hoc.
start(_Type, _StartArgs) ->
    erly_ad_hoc_deps:ensure(),
    erly_ad_hoc_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for erly_ad_hoc.
stop(_State) ->
    ok.
