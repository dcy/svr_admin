-module(util).
-compile(export_all).

%% 秒
unixtime() ->
    {M, S, _} = os:timestamp(),
    M * 1000000 + S.
%% 毫秒
longunixtime() ->
    {M, S, Ms} = os:timestamp(),
    M * 1000000000 + S*1000 + Ms div 1000.

%%向上取整
ceil(N) ->
    T = trunc(N),
    case N == T of
        true  -> T;
        false -> 1 + T
    end.

%%向下取整
floor(X) ->
    T = trunc(X),
    case (X < T) of
        true -> T - 1;
        _ -> T
    end.

%% term序列化，term转换为string格式，e.g., [{a},1] => "[{a},1]"
term_to_string(Term) ->
    binary_to_list(list_to_binary(io_lib:format("~w", [Term]))).

%% term序列化，term转换为bitstring格式，e.g., [{a},1] => <<"[{a},1]">>
term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~w", [Term])).

%% term反序列化，string转换为term，e.g., "[{a},1]"  => [{a},1]
string_to_term(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err -> undefined
            end;
        _Error ->
            undefined
    end.

%% term反序列化，bitstring转换为term，e.g., <<"[{a},1]">>  => [{a},1]
bitstring_to_term(undefined) -> undefined;
bitstring_to_term(BitString) ->
    string_to_term(binary_to_list(BitString)).

rand(Min, Max) when Max >= Min->
    case Min == Max of
        true ->
            Min;
        false ->
            random:seed(erlang:now()),
            random:uniform(Max - Min + 1) + Min -1
    end.

get_rand_list_item(List) ->
    Length = length(List),
    Index = util:rand(1, Length),
    lists:nth(Index, List).

get_rand_list_item(List, Amount) ->
    %?ASSERT(Amount >= 0, {amountCanNotLessThanZero}),
    Length = length(List),
    %?ASSERT(Length >= Amount, {noSoManyListItemsToGet, {Length, Amount}}),
    case Length =:= Amount of
        true -> List;
        false -> get_rand_list_item(List, [], Amount, Length, 0)
    end.

get_rand_list_item(_List, Items, Amount, _ListAmount, ItemsAmount) when Amount =:= ItemsAmount ->
    Items;
get_rand_list_item(List, Items, Amount, ListAmount, ItemsAmount) ->
    %Item = get_rand_list_item(List),
    Index = util:rand(1, ListAmount),
    Item = lists:nth(Index, List),
    UpdatedList = lists:delete(Item, List),
    UpdatedItems = [Item | Items],
    get_rand_list_item(UpdatedList, UpdatedItems, Amount, ListAmount-1, ItemsAmount+1).

datetime_to_unixtime(DateTime) ->
    etime:mktime(DateTime).

%%************************************************
%% keypos设置为1，set并且 get_ets 和 put_ets 配套使用
get_ets(Ets, Key) ->
    case ets:lookup(Ets, Key) of
        [] -> undefined; 
        [{Key, Value}] -> Value
    end.

put_ets(Ets, Key, Value) ->
    ets:insert(Ets, {Key, Value}).

del_ets(Ets, Key) ->
    ets:delete(Ets, Key).
%%************************************************

eval(ExprStr, Environ) ->
    BindFun = fun({Arg, Val}, Bindings) ->
            erl_eval:add_binding(Arg, Val, Bindings)
    end,
    NewBindings = lists:foldl(BindFun, erl_eval:new_bindings(), Environ),

    {ok, Scanned, _} = erl_scan:string(ExprStr),
    {ok, Parsed} = erl_parse:parse_exprs(Scanned),
    {value, Result, _NewBindings} = erl_eval:exprs(Parsed, NewBindings),
    Result.


modle_to_json(ModleObj) ->
    [{AttrName, ModleObj:AttrName()} || AttrName <- ModleObj:attribute_names()].

format_localtime_till_day(LocalTime) ->
    {{Y, M, D}, _} = LocalTime,
    lists:concat([Y, "-", M, "-", D]).

send_mail(ToAddress, Subject, Content) ->
    boss_mail:send("youxi.best dcy.dengcaiyun@gmail.com", ToAddress, Subject, Content).

get_page_from_req(Req) ->
    case Req:query_param("page") of
        undefined -> 1;
        PageStr -> list_to_integer(PageStr)
    end.


list_to_atom(List) when is_list(List) ->
    try
	  erlang:list_to_existing_atom(List)
    catch
        _:_->
            erlang:list_to_atom(List)
    end.

%% 转换为原子
to_atom( Term ) ->
    List = to_list(Term),
    try
	  erlang:list_to_existing_atom(List)
    catch
        _:_->
            erlang:list_to_atom(List)
    end.

%% 转换为list
to_list( Bin ) when is_binary( Bin ) ->
	binary_to_list( Bin ) ;
to_list( Integer) when is_integer( Integer ) ->
	integer_to_list( Integer ) ;
to_list( Atom ) when is_atom( Atom ) ->
	atom_to_list( Atom )  ;
to_list( Tuple ) when is_tuple( Tuple ) ->
	tuple_to_list( Tuple ) ;
to_list( List ) when is_list( List ) ->
	List ;
to_list( Integer ) when is_integer( Integer) ->
	integer_to_list( Integer ) ;
to_list( Float ) when is_float( Float) ->
	[ String ] = io_lib:format( "~p" , [ Float ] ) ,
	String .

%% 判断一个整数是否偶数
is_even(Number) ->
	(Number rem 2) == 0.
	

%% 判断一个整数是否奇数	
is_odd(Number) ->
	(Number rem 2) /= 0.

%% 转换成HEX格式的md5
md5(S) ->
    lists:flatten([io_lib:format("~2.16.0b",[N]) || N <- binary_to_list(erlang:md5(S))]).

localtime_to_str(Time) ->
    qdate:to_string("Y-m-d H:i:s", Time).

mapskeydelete(What, Key, [H|T]) ->
    case maps:get(Key, H) == What of
        true -> T;
        false -> [H|mapskeydelete(What, Key, T)]
    end;
mapskeydelete(_, _, []) -> [].

mapskeyreplace(What, Key, L, New) when is_list(L), erlang:is_map(New) ->
    mapskeyreplace3(What, Key, L, New).

mapskeyreplace3(What, Key, [H|T], New) ->
    case maps:get(Key, H) == What of
        true -> [New|T];
        false -> [H|mapskeyreplace3(What, Key, T, New)]
    end;
mapskeyreplace3(_, _, [], _) -> [].

mapskeyfind(_What, _Key, []) ->
    false;
mapskeyfind(What, Key, [H|T]) ->
    case maps:get(Key, H) == What of
        true -> H;
        false -> mapskeyfind(What, Key, T)
    end.

get_right_id(Id) ->
    case erlang:is_integer(Id) of
        true ->
            Id;
        false ->
            case erlang:is_list(Id) of
                true ->
                    erlang:list_to_integer(Id);
                false ->
                    erlang:error({idIllegal, Id})
            end
    end.

to_sql_timestamp(Time) ->
    qdate:to_string("Y-m-d H:i:s", Time).

now_time_str() ->
    to_sql_timestamp(calendar:local_time()).

render_not_found() ->
    {render_other, [{controller, "pages"}, {action, "not_found"}]}.

get_values_from_db_rows(Rows) ->
    get_values_from_db_rows(Rows, []).

get_values_from_db_rows([], Values) ->
    Values;
get_values_from_db_rows([Row | Rows], Values) ->
    [Value] = Row,
    get_values_from_db_rows(Rows, [Value|Values]).
    


%% for maps test
maps_tests() ->
    Fuck6 = #{key1 => "Fuck6", key2 => "You1"},
    Fuck1 = #{key1 => "Fuck1", key2 => "You1"},
    Fuck3 = #{key1 => "Fuck3", key2 => "You1"},
    Fuck2 = #{key1 => "Fuck2", key2 => "You1"},
    Fuck4 = #{key1 => "Fuck4", key2 => "You1"},
    Fuck5 = #{key1 => "Fuck5", key2 => "You1"},
    Fuck7 = #{key1 => "Fuck7", key2 => "YOU1"},
    Maps = [Fuck6, Fuck1, Fuck3, Fuck2, Fuck4, Fuck5],
    [Fuck6, Fuck1, Fuck2, Fuck4, Fuck5] = mapskeydelete("Fuck3", key1, Maps), 
    [Fuck6, Fuck1, Fuck7, Fuck2, Fuck4, Fuck5] = mapskeyreplace("Fuck3", key1, Maps, Fuck7), 
    Fuck3 = mapskeyfind("Fuck3", key1, Maps), 
    ok.

