:- module(mongo_util,
    [
        options_to_bitmask/3
    ]).

/** <module> Helpers.
 */

:- include(misc(common)).

%%  options_to_bitmask(Options, PredOptionToValue, BitMask) is semidet.
%
%   True if BitMask is an unsigned integer with bits set according to
%   which Options are given, where each option is mapped to a value
%   using PredOptionToValue.

options_to_bitmask(Options, Pred, BitMask) :-
    options_to_bitmask(Options, Pred, 0, BitMask).

options_to_bitmask([], _Pred, BitMask, BitMask).
options_to_bitmask([Option|Options], Pred, BitMask0, BitMask) :-
    call(Pred, Option, Value),
    !,
    BitMask1 is BitMask0 \/ Value,
    options_to_bitmask(Options, Pred, BitMask1, BitMask).
options_to_bitmask([Option|_], _, _, _) :-
    throw(mongo_error('unknown option', Option)).
