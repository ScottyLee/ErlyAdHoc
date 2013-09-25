-module (plist_utils).
-export ([decode_plist/1]).

decode_plist(FileName)->
	DecodeResult = os:cmd("plutil -convert json " ++ FileName),
	case DecodeResult of
		[] -> true;
		_ ->
			io:format("Error: ~p~n", [DecodeResult]),
			false
	end.