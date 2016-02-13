-module(fsp_utility).
-compile(export_all).

init() ->
    ok.

shuffle_list([]) ->
    [];
shuffle_list(L = [_]) ->
    L;
shuffle_list(L) ->
    {N1, L1, N2, L2} = split_list(L),
    L1S = shuffle_list(L1),
    L2S = shuffle_list(L2),
    riffle_lists(N1, L1S, N2, L2S, []).

split_list(L) ->
    split_list(L, 0, [], 0, [], left).
split_list([], N1, L1, N2, L2, _) ->
    {N1, L1, N2, L2};
split_list([H | L], N1, L1, N2, L2, left) ->
    split_list(L, N1 + 1, [H | L1], N2, L2, right);
split_list([H | L], N1, L1, N2, L2, right) ->
    split_list(L, N1, L1, N2 + 1, [H | L2], left).

riffle_lists(0, [], 0, [], Res) -> Res;
riffle_lists(N1, L1, N2, L2, Res) when N1 + N2 >= 1 ->
    U = random:uniform(N1 + N2),
    if
	U =< N1 ->
	    [H | R1] = L1,
	    riffle_lists(N1 - 1, R1, N2, L2, [H | Res]);
	U > N1 ->
	    [H | R2] = L2,
	    riffle_lists(N1, L1, N2 - 1, R2, [H | Res])
    end.
%%% hex coord = {A, B, C} when A + B + C = 0
%%% the axis are N/S, SE/NW, SW/NE, but each *direction*
%%% is +1/-1/0 on axis, so directions are NW, NE, W, E, SW, SE
hex_nbr(nw, {A, B, C}) when A + B + C =:= 0 ->
    {A + 1, B - 1, C};
hex_nbr(ne, {A, B, C}) when A + B + C =:= 0 ->
    {A + 1, B, C - 1};
hex_nbr(w, {A, B, C}) when A + B + C =:= 0 ->
    {A, B - 1, C + 1};
hex_nbr(e, {A, B, C}) when A + B + C =:= 0 ->
    {A, B + 1, C - 1};
hex_nbr(sw, {A, B, C}) when A + B + C =:= 0 ->
    {A - 1, B, C + 1};
hex_nbr(se, {A, B, C}) when A + B + C =:= 0 ->
    {A - 1, B + 1, C}.

%%% base directions cw and ccw

find_pair(_, []) ->
    error(not_found);
find_pair(A, [A, B | _]) ->
    B;
find_pair(A, [_ | C]) ->
    find_pair(A, C).



hex_dir(A) ->
    hex_nbr(A, {0, 0, 0}).
hex_dir(cw, A) ->
    find_pair(A, [ne, e, se, sw, w, nw, ne]);
hex_dir(ccw, A) ->
    find_pair(A, [ne, nw, w, sw, se, e, ne]).
%%% cone directions, degrees are clockwise for some reason
hex_cone_dir(cw, A) ->
    find_pair(A, [c0, c60, c120, c180, c240, c300, c0]);
hex_cone_dir(ccw, A) ->
    find_pair(A, [c0, c300, c240, c180, c120, c60, c0]).
hex_cone_side_dir(cw, A) ->
    find_pair(A, [c0, ne, c60, e, c120, se, c180, sw, c240, w, c300, nw, c0]);
hex_cone_side_dir(ccw, A) ->
    find_pair(A, [c0, nw, c300, w, c240, sw, c180, se, c120, e, c60, ne, c0]).

hex_add_coords({A, B, C}, {D, E, F}) when A + B + C =:= 0, D + E + F =:= 0 ->
    {A + D, B + E, C + F}.

hex_neg_coords({A, B, C}) when A + B + C =:= 0 ->
    {-A, -B, -C}.

hex_times({A, B, C}, D) when A + B + C =:= 0 ->
    {A * D, B * D, C * D}.

hex_rotate_coords(cw, {A, B, C}) when A + B + C =:= 0 ->
    {-B, -C, -A};
hex_rotate_coords(ccw, {A, B, C}) when A + B + C =:= 0 ->
    {-C, -A, -B}.

revcw(cw) -> ccw;
revcw(ccw) -> cw.

hex_distance({A, B, C}, {D, E, F}) when A + B + C =:= 0, D + E + F =:= 0 ->
    max(max(abs(A - D), abs(B - E)), abs(C - F)).

%%% cone area
hex_cone_strand(Distance, ConeDir, Clockwise, IncludeEnd, List) ->
    Dir0 = hex_cone_side_dir(revcw(Clockwise), ConeDir),
    {A, B, C} = hex_dir(Dir0),
    Start = hex_times(hex_dir(Dir0), Distance),
    Step = case Clockwise of cw -> {C, A, B}; ccw -> {B, C, A} end,
    Loop = fun Loop(L, N, X) ->
		   case N of 0 ->
			   L;
		       _ ->
			   Loop([X | L], N - 1, hex_add_coords(X, Step))
		   end
	   end,
    Loop(List, if IncludeEnd -> Distance + 1;
	       not IncludeEnd -> Distance end, Start).

hex_cone_area(Radius, ConeDir, Clockwise, IncludeEnd, List) ->
    Loop = fun Loop(L, N) ->
		   case N of 0 ->
			   L;
		       _ ->
			   Loop(
			     hex_cone_strand(N, ConeDir, Clockwise, IncludeEnd, L),
			     N - 1)
		   end
	   end,
    Loop(List, Radius).

hex_wide_cone_strand(NCones, Distance, StartConeDir, Clockwise, IncludeEnd, List) ->
    Loop = fun Loop(L, ConeDir, N) ->
		   case N of
		       0 -> L;
		       1 -> hex_cone_strand(Distance, ConeDir, Clockwise, IncludeEnd, L);
		       _ -> Loop(
			      hex_cone_strand(Distance, ConeDir, Clockwise, false, L),
			      hex_cone_dir(Clockwise, ConeDir),
			      N - 1)
		   end
	   end,
    Loop(List, StartConeDir, NCones).

hex_wide_cone_area(NCones, Radius, ConeDir, Clockwise, IncludeEnd, List) ->
    Loop = fun Loop(L, N) ->
		   case N of 0 ->
			   L;
		       _ ->
			   Loop(
			     hex_wide_cone_strand(NCones, N, ConeDir, Clockwise, IncludeEnd, L),
			     N - 1)
		   end
	   end,
    Loop(List, Radius).

hex_circle(Radius) ->
    hex_wide_cone_strand(6, Radius, c0, cw, false, []).
hex_ball(Radius) ->
    hex_wide_cone_area(6, Radius, c0, cw, false, [{0, 0, 0}]).
hex_cone(Radius, ConeDir) ->
    hex_cone_area(Radius, ConeDir, cw, true, []).
hex_double_cone(Radius, Dir) ->
    hex_wide_cone_area(2, Radius, hex_cone_side_dir(ccw, Dir), cw, true, []).
hex_half(Radius, ConeDir) ->
    hex_wide_cone_area(3, Radius, hex_cone_dir(ccw, ConeDir), cw, true, []).

			   
