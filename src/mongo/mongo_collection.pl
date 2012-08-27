:- module(mongo_collection,
    [
        new_collection/3,
        collection_database/2,
        collection_name/2,
        collection_namespace/2,
        collection_connection/2
    ]).

/** <module> Collection handling.
 */

:- include(misc(common)).

:- use_module(bson(bson), []).
:- use_module(misc(util), []).

%%  collection_get_database.
%
%   xxxxxxxxx

new_collection(Database, CollectionName, Collection) :-
    mongo_database:database_name(Database, DatabaseName),
    namespace_atom(DatabaseName, CollectionName, Namespace),
    Collection = collection(Database,Namespace).

collection_database(Collection, Database) :-
    util:get_arg(Collection, 1, Database).

collection_name(Collection, CollectionName) :-
    collection_namespace(Collection, Namespace),
    collection_without_namespace(Namespace, CollectionName).

collection_without_namespace(NamespaceCollection, Collection) :-
    namespace_parts(NamespaceCollection, [_Namespace|Rest]),
    namespace_parts(Collection, Rest).

namespace_parts(Atom, Parts) :-
    core:atomic_list_concat(Parts, '.', Atom).

collection_namespace(Collection, Namespace) :-
    util:get_arg(Collection, 2, Namespace).

collection_connection(Collection, Connection) :-
    collection_database(Collection, Database),
    mongo_database:database_connection(Database, Connection).

namespace_atom(DatabaseName, CollectionName, Namespace) :-
    namespace_parts(Namespace, [DatabaseName,CollectionName]).
