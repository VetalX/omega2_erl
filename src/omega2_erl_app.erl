-module(omega2_erl_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
        Dispatch = cowboy_router:compile([
                {'_', [
                        {"/", toppage_handler, []}
                ]}
        ]),
        {ok, _} = cowboy:start_http(http, 100, [{port, 8050}], [
                {env, [{dispatch, Dispatch}]}
        ]),
        {ok, _} = ranch:start_listener(tcp_echo, 1,
                ranch_tcp, [{port, 9876}], echo_protocol, []),
	omega2_erl_sup:start_link().

stop(_State) ->
	ok.
