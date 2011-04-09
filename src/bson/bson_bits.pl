:- module(bson_bits,
    [
        float_bytes/2,
        integer_bytes/4,
        unsigned_bytes/4,
        fits_in_32_bits/1,
        fits_in_64_bits/1
    ]).

% <module> Low-level bytes-to-number conversions.
%
% Some predicates are implemented in C.

:- use_foreign_library(foreign(bson_bits)).

:- include(misc(common)).

%%  float_bytes XXX
%
%   XXX

float_bytes(Float, Bytes) :-
    inbuilt:nonvar(Bytes),
    Bytes = [B0,B1,B2,B3,B4,B5,B6,B7],
    !,
    bytes_to_float(B0, B1, B2, B3, B4, B5, B6, B7, Float).
float_bytes(Float, Bytes) :-
    inbuilt:nonvar(Float),
    !,
    Bytes = [B0,B1,B2,B3,B4,B5,B6,B7],
    float_to_bytes(Float, B0, B1, B2, B3, B4, B5, B6, B7).

%%  integer_bytes(+Integer, +NumBytes, +Endian, ?Bytes) is semidet.
%%  integer_bytes(?Integer, +NumBytes, +Endian, +Bytes) is semidet.
%
%   Used to convert back-and-forth between 32/64-bit signed
%   integers and their byte representations.
%   May also be used to convert large (>8 bytes) NON-negative
%   integers to bytes, b XXXXXXXXXXXXXXXXXXXXXXXX
%   True if Bytes is the byte representation of Integer in
%   the given number of bytes and endianness. Endian must be either
%   little or big. If Integer is bound and negative, NumBytes must
%   be either 4 or 8. Integer must fit in NumBytes bytes.
%
%   Results are undefined if Integer cannot fit in NumBytes bytes,
%   or if Integer is negative when NumBytes is other than 4 or 8.

integer_bytes(Integer, NumBytes, Endian, Bytes) :-
    inbuilt:nonvar(Integer),
    !,
    integer_to_bytes(Integer, NumBytes, Endian, Bytes).
integer_bytes(Integer, _NumBytes, Endian, Bytes) :-
    inbuilt:nonvar(Bytes),
    !,
    bytes_to_integer(Endian, Bytes, Integer).

%%  integer_to_bytes
%
%   XXX

integer_to_bytes(Integer, 4, little, [B0,B1,B2,B3]) :- !,
    integer_to_bytes(Integer, B0, B1, B2, B3).

integer_to_bytes(Integer, 8, little, [B0,B1,B2,B3,B4,B5,B6,B7]) :- !,
    integer_to_bytes(Integer, B0, B1, B2, B3, B4, B5, B6, B7).

integer_to_bytes(Integer, N, big, Bytes) :- !,
    integer_to_bytes(Integer, N, little, BytesLittle),
    lists:reverse(BytesLittle, Bytes).

%%  bytes_to_integer
%
%   XXX

bytes_to_integer(little, [B0,B1,B2,B3], Integer) :- !,
    bytes_to_integer(B0, B1, B2, B3, Integer).

bytes_to_integer(little, [B0,B1,B2,B3,B4,B5,B6,B7], Integer) :- !,
    bytes_to_integer(B0, B1, B2, B3, B4, B5, B6, B7, Integer).

bytes_to_integer(big, Bytes, Integer) :- !,
    lists:reverse(Bytes, BytesLittle),
    bytes_to_integer(little, BytesLittle, Integer).

%%  unsigned_bytes
%
%   XXX

unsigned_bytes(Unsigned, NumBytes, Endian, Bytes) :-
    inbuilt:nonvar(Unsigned),
    !,
    unsigned_to_bytes(Unsigned, NumBytes, Endian, Bytes).
unsigned_bytes(Unsigned, _NumBytes, Endian, Bytes) :-
    inbuilt:nonvar(Bytes),
    !,
    bytes_to_unsigned(Endian, Bytes, Unsigned).

%%  unsigned_to_bytes
%
%   XXX

unsigned_to_bytes(Unsigned, N, little, Bytes) :- !,
    unsigned_to_bytes_aux(Unsigned, 0, N, Bytes).

unsigned_to_bytes(Unsigned, N, big, Bytes) :- !,
    unsigned_to_bytes(Unsigned, N, little, BytesLittle),
    lists:reverse(BytesLittle, Bytes).

unsigned_to_bytes_aux(_Unsigned, N, N, []) :- !.
unsigned_to_bytes_aux(Unsigned, N0, N, [Byte|Bytes]) :-
    Byte is (Unsigned >> (N0*8)) /\ 0xFF,
    N1 is N0 + 1,
    unsigned_to_bytes_aux(Unsigned, N1, N, Bytes).

%%  bytes_to_unsigned
%
%   XXX

bytes_to_unsigned(little, Bytes, Unsigned) :- !,
    bytes_to_unsigned_aux(Bytes, 0, 0, Unsigned).

bytes_to_unsigned(big, Bytes, Unsigned) :- !,
    lists:reverse(Bytes, BytesLittle),
    bytes_to_unsigned(little, BytesLittle, Unsigned).

bytes_to_unsigned_aux([], _N, Unsigned, Unsigned).
bytes_to_unsigned_aux([Byte|Bytes], N, Unsigned0, Unsigned) :-
    Unsigned1 is (Byte << (N*8)) \/ Unsigned0,
    N1 is N + 1,
    bytes_to_unsigned_aux(Bytes, N1, Unsigned1, Unsigned).

%%  fits_in_32_bits(+Integer) is semidet.
%
%   True if Integer can be stored as a signed 32-bit int.

fits_in_32_bits(Integer) :-
    -(2**(32-1)) =< Integer, Integer =< (2**(32-1))-1.

%%  fits_in_64_bits(+Integer) is semidet.
%
%   True if Integer can be stored as a signed 64-bit int.

fits_in_64_bits(Integer) :-
    -(2**(64-1)) =< Integer, Integer =< (2**(64-1))-1.

%%  bytes_to_float(
%       +B0:byte, +B1:byte, +B2:byte, +B3:byte,
%       +B4:byte, +B5:byte, +B6:byte, +B7:byte,
%       ?Float:float) is det.
%
%   True if Float is the floating point number represented by the
%   consecutive bytes (0..255) B0..B7 interpreted as a 64-bit
%   IEEE 754 double.

% Implemented in foreign library.

%%  bytes_to_integer(
%       +B0:byte, +B1:byte, +B2:byte, +B3:byte,
%       ?Integer:int) is det.
%
%   True if Integer is the integer represented by the consecutive
%   bytes (0..255) B0..B3 interpreted as a 32-bit little-endian integer.

% Implemented in foreign library.

%%  bytes_to_integer(
%       +B0:byte, +B1:byte, +B2:byte, +B3:byte,
%       +B4:byte, +B5:byte, +B6:byte, +B7:byte,
%       ?Integer:int) is det.
%
%   True if Integer is the integer represented by the consecutive
%   bytes (0..255) B0..B7 interpreted as a 64-bit little-endian integer.

% Implemented in foreign library.
