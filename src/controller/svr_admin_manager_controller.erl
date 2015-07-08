-module(svr_admin_manager_controller, [Req]).
-compile(export_all).
-include("svr.hrl").
-include("deps/simple_bridge/include/simple_bridge.hrl").
-define(CRASHES_PER_PAGE, 10).

list('GET', []) ->
    Svrs = get_clt_svrs(),
    Account = account_lib:is_login_cookie(Req),
    Histories = get_recent_histories(),
    {ok, [{account, Account}, {histories, Histories}, {svrs, Svrs}]}.

reload_confs('POST', [StrSvrId]) ->
    SvrId = erlang:list_to_integer(StrSvrId),
    Result = case is_the_svr_live(SvrId) of
                 false ->
                     "serverNotLive";
                 true ->
                     Svr = get_svr(SvrId),
                     #{node:=TheSvrNode, path:=Path} = Svr,
                     SvnUpCmd = lists:concat(["cd ", Path, "; svn up"]),
                     os:cmd(SvnUpCmd),
                     MakeCmd = lists:concat(["cd ", Path, "; ./rebar compile skip_deps=true"]),
                     os:cmd(MakeCmd),
                     reload(TheSvrNode, data_confs),
                     History = history:new(id, get_name(Req:cookie("account_id")), ?MANAGER_RELOAD_CONFS, calendar:local_time(), SvrId),
                     History:save(),
                     case validate_confs(TheSvrNode) of
                         ok -> "success";
                         Other -> Other
                     end
             end,
    {json, [{result, Result}]}.

reload_svr('POST', [StrSvrId]) ->
    SvrId = erlang:list_to_integer(StrSvrId),
    Result = case is_the_svr_live(SvrId) of
                 false ->
                     "serverNotLive";
                 true ->
                     Svr = get_svr(SvrId),
                     #{path:=Path, node:=TheSvrNode} = Svr,
                     SvnUpCmd = lists:concat(["cd ", Path, "; svn up"]),
                     os:cmd(SvnUpCmd),
                     MakeCmd = lists:concat(["cd ", Path, "; ./rebar compile"]),
                     os:cmd(MakeCmd),
                     reload(TheSvrNode, all),
                     History = history:new(id, get_name(Req:cookie("account_id")), ?MANAGER_RELOAD_SVR, calendar:local_time(), SvrId),
                     History:save(),
                     case validate_confs(TheSvrNode) of
                         ok -> "success";
                         Other -> Other
                     end
             end,
    {json, [{result, Result}]}.

reset_svr('POST', [StrSvrId]) ->
    SvrId = erlang:list_to_integer(StrSvrId),
    Svr = get_svr(SvrId),
    #{path:=Path, node:=Node} = Svr,
    case is_the_svr_live(SvrId) of
        false ->
            ok;
        true ->
            case net_kernel:connect_node(Node) of
                true ->
                    rpc:call(Node, xysvr, server_stop, []);
                false ->
                    erlang:error({canNotConnectTheNode, Node})
            end
    end,
    DbScriptPath = lists:concat([Path, "db_script"]),
    InitDbCmd = lists:concat(["cd ", DbScriptPath, "; python init_db.py"]),
    os:cmd(InitDbCmd),
    ScriptPath = lists:concat([Path, "script"]),
    StartSvrCmd = lists:concat(["cd ", ScriptPath, "; python start_daemon_server.py"]),
    os:cmd(StartSvrCmd),
    History = history:new(id, get_name(Req:cookie("account_id")), ?MANAGER_RESET_SVR, calendar:local_time(), SvrId),
    History:save(),
    {json, [{result, "success"}]}.



crash('GET', []) ->
    PageStr = case Req:query_param("page") of
                  undefined -> "1";
                  Other -> Other
              end,
    Account = account_lib:is_login_cookie(Req),
    Page = list_to_integer(PageStr),
    AllObjs = boss_db:find(crash, [], [{order_by, time}, {descending, true}]),
    Amount = length(AllObjs),
    TotalPages = case Amount rem ?CRASHES_PER_PAGE of
                     0 -> Amount div ?CRASHES_PER_PAGE;
                     _ -> Amount div ?CRASHES_PER_PAGE + 1
                 end,
    Crashes = case Page > TotalPages of
                  true ->
                      [];
                  false ->
                      Start = ?CRASHES_PER_PAGE * (Page-1) + 1,
                      lists:sublist(AllObjs, Start, ?CRASHES_PER_PAGE)
              end,
    PageInfo = [{total_pages, TotalPages}, {page_num, Page}],
    {ok, [{account, Account}, {crashes, Crashes}, {page_info, PageInfo}, {svrs, get_clt_svrs()}]};

crash('POST', []) ->
    Host = Req:post_param("host"),
    Port = Req:post_param("port"),
    Device = Req:post_param("device"),
    AccName = Req:post_param("acc_name"),
    Nick = Req:post_param("nick"),
    Dump = case Req:post_files() of
               [] ->
                   "";
               [FileObj] ->
                   %%todo: size 太大，忽略
                   #sb_uploaded_file{original_name=OriginalName, temp_file=TempFile} = FileObj,
                   SourceFile = lists:concat(["priv/static/dump/", OriginalName]),
                   file:copy(TempFile, SourceFile),
                   file:delete(TempFile),
                   OriginalName
           end,
    Crash = crash:new(id, Host, Port, Device, AccName, Nick, Dump, calendar:local_time()),
    case Crash:save() of
        {ok, _} -> {json, [{result, "success"}]};
        _ -> {json, [{result, "fail"}]}
    end.

del_crash('POST', []) ->
    CrashId = Req:post_param("crash_id"),
    Crash = boss_db:find(CrashId),
    Dump = erlang:binary_to_list(Crash:dump()),
    DumpFile = lists:concat(["priv/static/dump/", Dump]),
    file:delete(DumpFile),
    boss_db:delete(CrashId),
    {json, [{result, "success"}]}.

%is_the_svr_live() ->
%    {ok, TheSvrNode} = application:get_env(boss, the_svr_node),
%    net_kernel:connect_node(TheSvrNode).
is_the_svr_live(SvrId) ->
    Svrs = get_svrs(),
    Svr = util:mapskeyfind(SvrId, id, Svrs),
    #{node:=TheSvrNode} = Svr,
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

validate_confs(Node) ->
    case net_kernel:connect_node(Node) of
        true ->
            rpc:call(Node, lib_validate, validate_datas_for_rpc, []);
        false ->
            erlang:error({canNotConnectTheNode, Node})
    end.

get_db_id(Id) ->
    [_ModuleName, DbIdStr] = string:tokens(Id, "-"),
    erlang:list_to_integer(DbIdStr).

%get_recent_histories() ->
%    HistoriesObj = boss_db:find(history, [], [{limit, 20}, {order_by, time}, {descending, true}]),
%    %[[{who, History:who()}, {what, get_what(History:what())}, {time, History:time()}] || History <- HistoriesObj].
%    [#{who=>History:who(), what=>get_what(History:what()), time=>History:time()} || History <- HistoriesObj].
get_recent_histories(SvrId) ->
    HistoriesObj = boss_db:find(history, [{svr_id, equals, SvrId}], [{limit, 16}, {order_by, time}, {descending, true}]),
    [#{who=>History:who(), what=>get_what(History:what()), time=>History:time()} || History <- HistoriesObj].

get_recent_histories() ->
    HistoriesObj = boss_db:find(history, [], [{order_by, time}, {descending, true}, {limit, 16}]),
    [#{svr_name=>get_svr_name(History:svr_id()), who=>History:who(), what=>History:what(), time=>History:time(), what_str=>get_what(History:what())} || History <- HistoriesObj].

get_name(AccountId) ->
    Account = boss_db:find(AccountId),
    Account:name().

get_what(What) ->
    case What of
        ?MANAGER_RELOAD_CONFS -> unicode:characters_to_binary("热更配置");
        ?MANAGER_RELOAD_SVR -> unicode:characters_to_binary("热更整服");
        ?MANAGER_REBOOT_SVR -> unicode:characters_to_binary("重启服务");
        ?MANAGER_RESET_SVR -> unicode:characters_to_binary("清数据库")
    end.

get_svr_name(SvrId) ->
    Svrs = get_clt_svrs(),
    Svr = util:mapskeyfind(SvrId, id, Svrs),
    case Svr of
        undefined -> unicode:characters_to_binary("不存在或已删除");
        _ -> maps:get(name, Svr)
    end.


get_svrs() ->
    {ok, Svrs} = application:get_env(boss, svrs),
    Svrs.

get_svr(SvrId) ->
    Svrs = get_svrs(),
    util:mapskeyfind(SvrId, id, Svrs).

get_clt_svrs() ->
    Svrs = get_svrs(),
    Fun = fun(Svr) ->
                  #{id:=Id, name:=Name, ip:=Ip, port:=Port, log_port:=LogPort} = Svr,
                  #{id=>Id, name=>unicode:characters_to_binary(Name), ip=>Ip, port=>Port, is_live=>is_the_svr_live(Id), log_port=>LogPort}
          end,
    lists:map(Fun, Svrs).

