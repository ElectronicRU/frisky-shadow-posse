-module(fspcg).
-behaviour(application).
-export([start/2, stop/1]).

start(normal, _Args)->
    ok.

stop(_State)->
    ok.
