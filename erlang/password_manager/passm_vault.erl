-module(passm_vault).

%% The vault plaintext format is intentionally dead simple:
%%
%%   github: mysecretpassword
%%   work_email: another_password
%%   ssh_key: yet_another
%%
%% Lines starting with # are comments and are preserved on round-trip... 
%% actually stripped for simplicity in this prototype.
%% Empty lines are ignored.
%%
%% The encrypted vault file format (binary):
%%   <<SaltLen:8, Salt/binary,
%%     IVLen:8,   IV/binary,
%%     TagLen:8,  Tag/binary,
%%     Ciphertext/binary>>

-export([
    parse/1,
    serialize/1,
    read_encrypted/1,
    write_encrypted/4,
    lookup/2
]).

%% Parse plaintext vault text into a map of #{name => password}
parse(Binary) when is_binary(Binary) ->
    Lines = binary:split(Binary, <<"\n">>, [global]),
    lists:foldl(fun(Line, Acc) ->
        Trimmed = trim(Line),
        case Trimmed of
            <<>>                    -> Acc;  %% empty line
            <<"#", _/binary>>       -> Acc;  %% comment
            _ ->
                case binary:split(Trimmed, <<": ">>) of
                    [Key, Value] ->
                        maps:put(trim(Key), trim(Value), Acc);
                    _ ->
                        %% try splitting on just ":"
                        case binary:split(Trimmed, <<":">>) of
                            [Key, Value] ->
                                maps:put(trim(Key), trim(Value), Acc);
                            _ ->
                                Acc  %% malformed line, skip
                        end
                end
        end
    end, #{}, Lines).

%% Serialize a map back to plaintext vault text
serialize(Map) when is_map(Map) ->
    Lines = maps:fold(fun(Key, Value, Acc) ->
        [<<Key/binary, ": ", Value/binary, "\n">> | Acc]
    end, [], Map),
    iolist_to_binary(lists:sort(Lines)).

%% Lookup a password by name (case-insensitive key match)
lookup(Name, Map) when is_binary(Name), is_map(Map) ->
    %% Try exact match first
    case maps:find(Name, Map) of
        {ok, Value} -> {ok, Value};
        error ->
            %% Try case-insensitive
            Lower = string:lowercase(Name),
            Found = maps:fold(fun(K, V, Acc) ->
                case string:lowercase(K) of
                    Lower -> {ok, V};
                    _     -> Acc
                end
            end, not_found, Map),
            case Found of
                {ok, _} = R -> R;
                not_found   -> {error, not_found}
            end
    end.

%% Read an encrypted vault file, return {Salt, IV, Tag, Ciphertext}
read_encrypted(Path) ->
    case file:read_file(Path) of
        {ok, Binary} ->
            decode_vault_binary(Binary);
        {error, Reason} ->
            {error, Reason}
    end.

%% Write encrypted vault to file
write_encrypted(Path, Salt, IV, {Tag, Ciphertext}) ->
    Binary = encode_vault_binary(Salt, IV, Tag, Ciphertext),
    file:write_file(Path, Binary).

%% ---- Internal ----

encode_vault_binary(Salt, IV, Tag, Ciphertext) ->
    SaltLen = byte_size(Salt),
    IVLen   = byte_size(IV),
    TagLen  = byte_size(Tag),
    <<SaltLen:8, Salt/binary,
      IVLen:8,   IV/binary,
      TagLen:8,  Tag/binary,
      Ciphertext/binary>>.

decode_vault_binary(<<SaltLen:8, Rest0/binary>>) ->
    <<Salt:SaltLen/binary, IVLen:8, Rest1/binary>> = Rest0,
    <<IV:IVLen/binary, TagLen:8, Rest2/binary>> = Rest1,
    <<Tag:TagLen/binary, Ciphertext/binary>> = Rest2,
    {ok, Salt, IV, Tag, Ciphertext};
decode_vault_binary(_) ->
    {error, bad_format}.
