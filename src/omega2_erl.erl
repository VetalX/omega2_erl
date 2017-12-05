-module(omega2_erl).
-export([start/0, stop/0]).

start() ->
    {ok, _} = application:ensure_all_started(omega2_erl).

stop() ->
    application:stop(omega2_erl).
