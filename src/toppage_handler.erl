%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(toppage_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
	{ok, DbHost} = application:get_env(omega2_erl, db_host),
	{ok, DbUser} = application:get_env(omega2_erl, db_user),
	{ok, DbPassword} = application:get_enc(omega2_erl, db_password),
	{ok, DbDatabase} = application:get_env(omega2_erl, db_database),
	{ok, Conn} = epgsql:connect(DbHost, DbUser, DbPassword, [{database, DbDatabase}, {timeout, 4000}]),
	io:format("Conn ~p", [Conn]),

	{ok, Req, undefined}.

handle(Req, State) ->
	io:format("State ~p", [State]),
	{ok, Req2} = cowboy_req:reply(200, [
		{<<"content-type">>, <<"text/plain">>}
	], <<"Hello world!">>, Req),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.
