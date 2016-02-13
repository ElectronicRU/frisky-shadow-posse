-type id() :: integer().
-type action() :: tuple().
-type tag() :: atom().
-type trigger() :: {atom(), id() | self | any,
		    fun((atom(), list(), id())->{[action()], list()}), tag()}.
-type position() :: {integer(), integer(), integer()}.

-record(ccard, {
	  name :: atom() | string(), % an unique identifier for the card
	  cost :: non_neg_integer(), % associated cost
	  type :: creature | weapon | spell, % either creature, weapon, or spell?..
	  damage :: non_neg_integer(), % either the attack damage for creature/weapon, or the damage for the spell
	  attacks :: non_neg_integer(), % number of attacks for creature/weapon
	  life :: non_neg_integer(),    % max life for creature
	  text = [] :: [action()], % card "on-play" text in a format understood by man and machine alike
	  triggers = [] :: [trigger()], % ongoing effects for this card, in varying format
	  extra = #{} :: #{} 	% extra state for triggers
	}).


-record(cstate, { 				% creature state
	  weapon :: id() | undefined,	      % active weapon, if any
	  damaged = 0 :: non_neg_integer(),   % damage sustained
	  attacked = 0 :: non_neg_integer(), % attacks done this turn
	  moved = 0 :: non_neg_integer(),    % tiles moved this turn
	  position :: position()		    % position on the board, if any
	}).

-record(wstate,	{	  % weapon state
	  wielder :: id() % current wielder (cannot exist without one)
	 }).

-record(hstate, {				% state of card in hand
	  cost_mod = 0 :: integer()		% cost modification
	}).

-type state() :: #cstate{} | #wstate{} | #hstate{}.
-record(object, {
	  id :: id(),				% unique object id
	  def :: #ccard{},			% object definition
	  owner :: id(),			% owner id
	  state :: state()
	 }).
