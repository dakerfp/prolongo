:- module(bson,
    [
        term_bson/2,
        version/1,
        bson_version/1
    ]).

% <module> BSON encoder/decoder.
%
% Specification: http://bsonspec.org/

:- use_module(bson_decoder, []).
:- use_module(bson_encoder, []).

:- include(misc(common)).

%%  version(?Version:list) is det.
%
%   True if Version is a list representing the major, minor
%   and patch version numbers of this library.

version([0,0,0]).

%%  bson_version(?Version:list) is det.
%
%   True if Version is a list representing the major and minor
%   version numbers of the implemented BSON format.

bson_version([1,0]).

%%  term_bson(+Term:list(pair), ?Bson:list(byte)) is semidet.
%%  term_bson(?Term:list(pair), +Bson:list(byte)) is semidet.
%
%   True if Bson is the BSON byte-encoding of Term.
%
%   @throws bson_error(Reason)

term_bson(Term, Bson) :-
    nonvar(Term),
    !,
    bson_encoder:term_to_bson(Term, Bson).
term_bson(Term, Bson) :-
    nonvar(Bson),
    !,
    bson_decoder:bson_to_term(Bson, Term).
