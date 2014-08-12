-module(account_lib).
-compile(export_all).

-include("svr.hrl").

is_login(Req) ->
    case Req:cookie("account_id") of
        undefined -> false;
        [] -> false;
        AccountId -> AccountId
    end.

is_login_cookie(Req) ->
    case is_login(Req) of
        false ->
            false;
        AccountId ->
            case get_account(AccountId) of
                undefined ->
                    false;
                Account ->
                    case Account:session_identifier() =:= Req:cookie("session_id") of
                        false -> false;
                        true -> Account 
                    end
            end
    end.


require_login(Req) ->
    case is_login_cookie(Req) of
        false ->
            {redirect, "/account/login"};
        Account ->
            {ok, Account}
    end.

get_account(AccountId) ->
    case boss_db:find(AccountId) of
        undefined -> 
            undefined;
        Account ->
            Account
    end.
