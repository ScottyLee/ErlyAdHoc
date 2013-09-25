-module (erly_ad_hoc_dispatcher).
-export ([dispatch/1]).

action_field() ->
	<<"action">>.

type_field() ->
	<<"type">>.

dispatch(Data) ->
	{struct, JsonStruct} = mochijson2:decode(binary_to_list(Data)),
	{struct, Json} = proplists:get_value(<<"json">>, JsonStruct),
	A = proplists:get_value(action_field(), Json),
	T = proplists:get_value(type_field(), Json),
	Action = binary_to_atom(A, utf8),
	Type = binary_to_atom(T, utf8),
	ResultAction = concat_atom(Type, Action),
	Result = stat_server_events:ResultAction(Json),
	DataOut = mochijson2:encode(Result),
	DataOut.

concat_atom(AtomPrefix, AtomPostfix)->
	binary_to_atom(list_to_binary(lists:concat([AtomPrefix,"_",AtomPostfix])),utf8).