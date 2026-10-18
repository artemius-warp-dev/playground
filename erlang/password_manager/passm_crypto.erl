-module(passm_crypto).

-export([
    derive_key/2,
    derive_key/3,
    encrypt/2,
    decrypt/3,
    new_salt/0,
    secure_wipe/1
]).

-define(ITERATIONS, 200000).
-define(KEY_LEN, 32).      %% 256 bits for AES-256
-define(SALT_LEN, 16).
-define(IV_LEN, 12).       %% 96 bits, standard for GCM
-define(TAG_LEN, 16).

%% Derive a key from master password + salt using PBKDF2-HMAC-SHA256
derive_key(Password, Salt) ->
    derive_key(Password, Salt, ?ITERATIONS).

derive_key(Password, Salt, Iterations) ->
    crypto:pbkdf2_hmac(sha256, Password, Salt, Iterations, ?KEY_LEN).

%% Encrypt plaintext binary, returns {Salt, IV, Tag, Ciphertext}
%% The key is derived internally from the password so the salt can be stored
encrypt(Password, Plaintext) when is_binary(Password), is_binary(Plaintext) ->
    Salt = new_salt(),
    Key  = derive_key(Password, Salt),
    IV   = crypto:strong_rand_bytes(?IV_LEN),
    AAD  = <<>>,  %% no additional authenticated data for now
    {Ciphertext, Tag} = crypto:crypto_one_time_aead(
        aes_256_gcm, Key, IV, Plaintext, AAD, ?TAG_LEN, true
    ),
    {Salt, IV, Tag, Ciphertext}.

%% Decrypt. Returns {ok, Plaintext} | {error, bad_password}
decrypt(Password, Salt, {IV, Tag, Ciphertext}) when is_binary(Password) ->
    Key = derive_key(Password, Salt),
    AAD = <<>>,
    case crypto:crypto_one_time_aead(
        aes_256_gcm, Key, IV, Ciphertext, AAD, Tag, false
    ) of
        error     -> {error, bad_password};
        Plaintext -> {ok, Plaintext}
    end.

new_salt() ->
    crypto:strong_rand_bytes(?SALT_LEN).

%% Overwrite a file with zeros before deleting (best-effort on SSDs)
secure_wipe(Path) ->
    case file:read_file_info(Path) of
        {ok, Info} ->
            Size = Info#file_info.size,
            Zeros = binary:copy(<<0>>, Size),
            file:write_file(Path, Zeros),
            file:delete(Path);
        {error, _} ->
            ok
    end.
