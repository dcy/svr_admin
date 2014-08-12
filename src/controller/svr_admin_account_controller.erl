-module(svr_admin_account_controller, [Req]).
-compile(export_all).

login('GET', []) ->
    {ok, []};

login('POST', []) ->
    Name = Req:post_param("name"),
    Password = Req:post_param("password"),
    case boss_db:find(account, [{name, Name}]) of
        [Account] ->
            case Account:check_password(Password) of
                true ->
                    {json, [{result, "success"}], Account:login_cookies()};
                false ->
                    {json, [{result, "passwordWrong"}]}
            end;
        [] ->
            {json, [{result, nameNotExist}]}
    end.

logout('GET', []) ->
    {redirect, "/", [mochiweb_cookies:cookie("account_id", "", [{path, "/"}]),
                                  mochiweb_cookies:cookie("session_id", "", [{path, "/"}])]}.

change_password('POST', []) ->
    case account_lib:is_login_cookie(Req) of
        false ->
            {redirect, "/account/login"};
        Account ->
            OriPassword = Req:post_param("ori_password"),
            NewPassword = Req:post_param("new_password"),
            case NewPassword =/= [] of
                true ->
                    case Account:check_password(OriPassword) of
                        true ->
                            NewAccount  = Account:set(password, NewPassword),
                            NewAccount:save(),
                            {json, [{result, "success"}]};
                        false ->
                            {json, [{result, "passwordWrong"}]}
                    end;
                false ->
                    {json, [{result, "fail"}]}
            end
    end.
