-module(svr_admin_pages_controller, [Req]).
-compile(export_all).
-include("svr.hrl").

before_(Action, Arg1, Arg2) ->
    account_lib:require_login(Req).

lost('GET', [], Account) ->
    {ok, [{acocunt, Account}]}.
