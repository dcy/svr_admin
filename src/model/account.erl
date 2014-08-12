-module(account, [Id, Name, Password]).
-compile(export_all).
-include("svr.hrl").

session_identifier() ->
    mochihex:to_hex(erlang:md5("svr_admin" ++ Id)).

login_cookies() ->
    AccountCookie = mochiweb_cookies:cookie("account_id", Id, [{path, "/"}]),
    [mochiweb_cookies:cookie("account_id", Id, [{path, "/"}]),
     mochiweb_cookies:cookie("session_id", session_identifier(), [{path, "/"}])].

check_password(PasswordInput) ->
    PasswordInput =:= erlang:binary_to_list(Password).
