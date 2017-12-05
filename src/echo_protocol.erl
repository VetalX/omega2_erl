%% Feel free to use, reuse and abuse the code in this file.

-module(echo_protocol).
-behaviour(ranch_protocol).

-export([start_link/4]).
-export([init/4]).

start_link(Ref, Socket, Transport, Opts) ->
	Pid = spawn_link(?MODULE, init, [Ref, Socket, Transport, Opts]),
	{ok, Pid}.

init(Ref, Socket, Transport, _Opts = []) ->
	ok = ranch:accept_ack(Ref),
	loop(Socket, Transport).

loop(Socket, Transport) ->
	case Transport:recv(Socket, 0, 5000) of
		{ok, Data} ->
			%% Transport:send(Socket, Data),
                        %% io:format("Data ~p~n", [Data]),
			case parse_val(Data) of
				error -> do_nothing;
				Pos ->
					io:format("~p~n", ["fast-gpio pwm 15 50 "++Pos])
					%% os:cmd("fast-gpio pwm 15 50 "++Pos)
			end,
			loop(Socket, Transport);
		_ ->
			ok = Transport:close(Socket)
	end.

parse_val(<<"sr1 ", Rest:4/binary, _/binary>>) ->
	try 
		float_to_list(binary_to_float(Rest),[{decimals,2}])
	catch _:_ ->
		error
	end;

parse_val(A) ->
	io:format("Wrong data: ~p~n", [A]),
	ok.

% map_float(X, InMin, InMax, OutMin, OutMax) ->
%	(X - InMin) * (OutMax - OutMin) / (InMax - InMin) + OutMin.
