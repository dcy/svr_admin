-module(svr_admin_manager_controller, [Req]).
-compile(export_all).
-include("svr.hrl").
-include("deps/simple_bridge/include/simple_bridge.hrl").

list('GET', []) ->
    Account = account_lib:is_login_cookie(Req),
    Histories = get_recent_histories(),
    {ok, [{account, Account}, {histories, Histories}]}.

reload_confs('POST', []) ->
    Result = case is_the_svr_live() of
                 false ->
                     "serverNotLive";
                 true ->
                     {ok, Path} = application:get_env(svr_admin, the_svr_path),
                     SvnUpCmd = lists:concat(["cd ", Path, "; svn up"]),
                     os:cmd(SvnUpCmd),
                     MakeCmd = lists:concat(["cd ", Path, "; ./rebar compile"]),
                     os:cmd(MakeCmd),
                     {ok, TheSvrNode} = application:get_env(svr_admin, the_svr_node),
                     reload(TheSvrNode, data_confs),
                     History = history:new(id, get_name(Req:cookie("account_id")), ?MANAGER_RELOAD_CONFS, calendar:local_time()),
                     History:save(),
                     "success" 
             end,
    {json, [{result, Result}]}.

reload_svr('POST', []) ->
    Result = case is_the_svr_live() of
                 false ->
                     "serverNotLive";
                 true ->
                     {ok, Path} = application:get_env(svr_admin, the_svr_path),
                     SvnUpCmd = lists:concat(["cd ", Path, "; svn up"]),
                     os:cmd(SvnUpCmd),
                     MakeCmd = lists:concat(["cd ", Path, "; ./rebar compile"]),
                     os:cmd(MakeCmd),
                     {ok, TheSvrNode} = application:get_env(svr_admin, the_svr_node),
                     reload(TheSvrNode, all),
                     History = history:new(id, get_name(Req:cookie("account_id")), ?MANAGER_RELOAD_SVR, calendar:local_time()),
                     History:save(),
                     "success" 
             end,
    {json, [{result, Result}]}.

crash('GET', []) ->
    Account = account_lib:is_login_cookie(Req),
    Crashes = boss_db:find(crash, []),
    {ok, [{account, Account}, {crashes, Crashes}]};

crash('POST', []) ->
    Host = Req:post_param("host"),
    Port = Req:post_param("port"),
    AccId = Req:post_param("acc_id"),
    AccName = Req:post_param("acc_name"),
    Uid = Req:post_param("uid"),
    Nick = Req:post_param("nick"),
    Stacktrace = Req:post_param("stacktrace"),
    Dump = case Req:post_files() of
               [] ->
                   ?TRACE_VAR(empty),
                   "";
               [FileObj] ->
                   ?TRACE_VAR(FileObj),
                   %%todo: size 太大，忽略
                   #sb_uploaded_file{original_name=OriginalName, temp_file=TempFile} = FileObj,
                   SourceFile = lists:concat(["priv/static/dump/", OriginalName]),
                   file:copy(TempFile, SourceFile),
                   file:delete(TempFile),
                   OriginalName
           end,
    Crash = crash:new(id, Host, Port, AccId, AccName, Uid, Nick, Stacktrace, Dump, calendar:local_time()),
    case Crash:save() of
        {ok, _} -> {json, [{result, "success"}]};
        _ -> {json, [{result, "fail"}]}
    end.

is_the_svr_live() ->
    {ok, TheSvrNode} = application:get_env(svr_admin, the_svr_node),
    net_kernel:connect_node(TheSvrNode).



reload(Node, Modules) ->
    IsNotify = "notify",
    case net_kernel:connect_node(Node) of
        true ->
            rpc:call(Node, c, l, [xysvr_hu]),
            FailMods = rpc:call(Node, xysvr_hu, reload, [Modules, IsNotify]),
            case FailMods of
                [] -> io:format("All Mods reload success~n");
                _ -> io:format("This Mods reload fail: ~p~n", [FailMods])
            end;
        false ->
            erlang:error({canNotConnectTheNode, Node})
    end.

get_db_id(Id) ->
    [_ModuleName, DbIdStr] = string:tokens(Id, "-"),
    erlang:list_to_integer(DbIdStr).

get_recent_histories() ->
    HistoriesObj = boss_db:find(history, [], [{limit, 20}, {order_by, time}, {descending, true}]),
    [[{who, History:who()}, {what, get_what(History:what())}, {time, History:time()}] || History <- HistoriesObj].

get_name(AccountId) ->
    Account = boss_db:find(AccountId),
    Account:name().

get_what(What) ->
    case What of
        ?MANAGER_RELOAD_CONFS -> unicode:characters_to_binary("热更配置");
        ?MANAGER_RELOAD_SVR -> unicode:characters_to_binary("热更整服");
        ?MANAGER_REBOOT_SVR -> unicode:characters_to_binary("重启服务")
    end.
