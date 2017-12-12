%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(toppage_handler).

-record(state, {
	     pg_conn
	 }). 

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
	{ok, DbHost} = application:get_env(omega2_erl, db_host),
	{ok, DbUser} = application:get_env(omega2_erl, db_user),
	{ok, DbPassword} = application:get_env(omega2_erl, db_password),
	{ok, DbDatabase} = application:get_env(omega2_erl, db_database),
	{ok, PgConn} = epgsql:connect(DbHost, DbUser, DbPassword, [{database, DbDatabase}, {timeout, 4000}]),
	{ok, Req, #state{pg_conn = PgConn}}.

handle(Req, #state{pg_conn = PgConn} = State) ->
	io:format("State ~p~n", [State]),
	{ok, Cols, Rows} = 
            epgsql:squery(PgConn, "select temperature, 
                                          humidity, 
                                          to_char(dt, 'hh24:mi') as time
                                     from dht22 
			            order by id desc 
			            limit 100;"),
	Columns = [Col || {column,Col,_,_,_,_} <- Cols],
	Propl = lists:foldl(fun(R, Acc) -> 
		               [lists:zip(Columns, tuple_to_list(R)) | Acc]
			    end, [], Rows),

	io:format("DbRes ~p~n", [jsx:encode(Propl)]),

	{ok, Req2} = cowboy_req:reply(200, [
		{<<"content-type">>, <<"application/json">>}
	], jsx:encode(Propl), Req),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.
