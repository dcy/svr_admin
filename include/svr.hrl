-define(SECRET_STRING, "yxq best").

-define(CACHE_PROCESS_AMOUNT, 10).

-define(ACCOUNT_TYPE_COMMON, 1).
-define(ACCOUNT_TYPE_ADMIN, 2).

-define(ACCOUNT_STATUS_NOT_ACTIVATE, 0).
-define(ACCOUNT_STATUS_IS_ACTIVATE, 1).

-define(SEX_MALE, 1).
-define(SEX_FEMALE, 2).

-define(IMAGES_PER_PAGE, 20).

-define(DEBUG_MSG(Str), lager:debug(Str)).
-define(DEBUG_MSG(Format, Args), lager:debug(Format, Args)).
-define(INFO_MSG(Str), lager:info(Str)).
-define(INFO_MSG(Format, Args), lager:info(Format, Args)).
-define(NOTICE_MSG(Str), lager:notice(Str)).
-define(NOTICE_MSG(Format, Args), lager:notice(Format, Args)).
-define(WARNING(Str), lager:warning(Str)).
-define(WARNING_MSG(Format, Args), lager:warning(Format, Args)).
-define(ERROR_MSG(Str), lager:error(Str)).
-define(ERROR_MSG(Format, Args), lager:error(Format, Args)).
-define(CRITICAL_MSG(Str), lager:critical(Str)).
-define(CRITICAL_MSG(Format, Args), lager:critical(Format, Args)).

-define(TRACE_VAR(Arg), io:format("~n******~nModule: ~p, Line: ~p, ~nMy print's ~p is ~p~n******~n", [?MODULE, ?LINE, ??Arg, Arg])).

-define(ASSERT(BoolExpr, Msg), ((fun() ->
                                         case (BoolExpr) of
                                             true -> void;
                                             _V -> erlang:error(Msg)
                                         end
                                 end)())).


%%%%%%%%操作相关定义%%%%%%%%
-define(MANAGER_RELOAD_CONFS, 1).
-define(MANAGER_RELOAD_SVR, 2).
-define(MANAGER_REBOOT_SVR, 3).






%%%%%%%%%%%%%%%% CODE %%%%%%%%%%%%%%%%
-define(SUCCESS, 0).
-define(FAIL, -1).


%% register
-define(EMAIL_ALREADY_REGISTER, 1).
-define(EMAIL_REGISTER_NOT_ACTIVATE, 2).
-define(NAME_ALREADY_REGISTER, 3).

%% login
-define(EMAIL_NOT_REGISTER, 1).
-define(PASSWORD_WRONG, 2).


