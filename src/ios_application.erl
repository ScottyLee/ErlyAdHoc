-module(ios_application).
-compile(export_all).


%unpack ipa file for prepare output
unpack(Path, TmpDir)->
	UnzipResult = os:cmd("unzip " ++ Path ++ " -d priv/www/tmp/" ++ TmpDir ++ " | grep Info.plist"),
	FileName = (UnzipResult -- "  inflating: ") -- "  \n",
	
	plist_utils:decode_plist(FileName),
	
	BuildInfo = file_utils:readlines(FileName).



