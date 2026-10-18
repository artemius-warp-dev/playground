# passm — a minimal password manager in pure Erlang

A self-contained, zero-dependency password manager for Linux. Download one binary, run it, done.

## Security model

- Master password never stored anywhere
- Key derivation: PBKDF2-HMAC-SHA256 with 200,000 iterations
- Encryption: AES-256-GCM (authenticated encryption)
- Decrypted vault lives only in memory (in a short-lived daemon)
- Daemon auto-exits after 15 minutes of inactivity
- Clipboard is automatically cleared after 30 seconds
- Plaintext vault file is overwritten with zeros before deletion on `seal`

## Installation (end user)

```bash
# Download the binary from GitHub Releases
curl -L https://github.com/yourname/passm/releases/latest/download/passm_linux_amd64 -o passm
chmod +x passm
```

That's it. No Erlang installation required.

## Usage

### First time setup

Create a `vault.txt` in the current directory:

```
github: mysecretpassword
work_email: another_password
ssh_server: yet_another_one
```

Then seal (encrypt) it:

```bash
./passm seal
```

This encrypts `vault.txt` → `vault.enc` and securely wipes `vault.txt`. Store `vault.enc` wherever you like (it's safe to back up to cloud storage).

### Daily use

```bash
./passm get github        # copies password to clipboard for 30s
./passm get work_email
./passm list              # show all stored names
./passm lock              # manually stop daemon + wipe memory
```

On first `get`, you'll be prompted for your master password. A daemon starts and holds the decrypted vault in memory for 15 minutes. Subsequent `get` calls within that window are instant.

### Editing passwords

```bash
./passm unseal            # decrypts vault.enc → vault.txt
# edit vault.txt in your editor
./passm seal              # re-encrypts, wipes vault.txt
```

## Building from source (requires Erlang + rebar3)

```bash
git clone https://github.com/yourname/passm
cd passm
rebar3 burrito export
# binary appears in ./burrito_out/passm_linux_amd64
```

## Vault file format

Plain text, one entry per line:

```
name: password
another_name: another_password
# lines starting with # are comments (stripped on seal)
```

## Project structure

```
src/
  passm_main.erl      CLI entry point, command dispatch
  passm_crypto.erl    PBKDF2 key derivation, AES-256-GCM encrypt/decrypt
  passm_vault.erl     Vault file format: parse, serialize, read/write encrypted
  passm_daemon.erl    gen_server: holds decrypted vault in memory, Unix socket server
  passm_client.erl    Connects to daemon, starts it if needed
  passm_clipboard.erl Clipboard copy via xclip/xsel/wl-copy, auto-clear
  passm_app.erl       OTP application callback
  passm_sup.erl       OTP supervisor
```

## Known limitations (prototype)

- Linux only (for now)
- Clipboard requires `xclip`, `xsel`, or `wl-copy` to be installed
- The `stty -echo` password prompt trick works in most terminals but not all
- Daemon spawning in `passm_client` is simplified; production version should fork a detached OS process
