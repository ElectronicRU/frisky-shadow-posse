-module(fsp_ccard).
-include("cards.hrl").
-include_lib("stdlib/include/assert.hrl").

-type registry() :: gb_trees:tree(id(), #object{}).
-type creature() :: #object{state :: #cstate{}}.
-type board() :: #{position()=>creature()}.


unique_id() ->
    {uid, erlang:unique_integer()}.

ensure_mnesia_table()->
    case mnesia:create_table(fsp_card_list,
			     [{attributes,
			       record_info(fields, ccard)},
			      {majority, true},
			      {record_name, ccard},
			      {disc_copies, [node()]}])
    of
	{atomic, ok} ->
	    ok;
	{error, {already_exists, _}} ->
	    ok;
	C = {error, _} ->
	    exit(C)
    end.

-spec get_ccard_by_name(atom()) -> #ccard{}.
get_ccard_by_name(Name) ->
    lists:hd(mnesia:dirty_read(fsp_card_list, Name)).

-spec registry_load(registry(), id()) -> #object{}.
registry_load(Registry, Id) ->
    Result = gb_trees:get(Id, Registry),
    ?assertEqual(Result#object.id, Id),			% they all start with id
    Result.

-spec registry_store(registry(), #object{}) -> registry().
registry_store(Registry, Object) ->
    gb_trees:insert(Object#object.id, Object, Registry).


-spec board_get(board(), position()) -> creature().
board_get(Board, Position) ->
    #{Position := Result} = Board,
    ?assertEqual(Result#object.state#cstate.position, Position),
    Result.

-spec board_put(board(), creature()) -> board().
board_put(Board, Creature) ->
    Position = Creature#object.state#cstate.position,
    ?assertEqual(maps:find(Board, Position), error),
    Board#{Position => Creature}.
