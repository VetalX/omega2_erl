#!/bin/sh
exec erl -pa ebin/ deps/*/ebin \
         -sname omega2_erl \
         -boot start_sasl \
	 -config env/master \
         -s omega2_erl

