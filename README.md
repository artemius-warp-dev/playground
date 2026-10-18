# playground

Small experiments, exercises and prototypes that are too small for a repository
of their own. Nothing here is production code; each folder is self-contained.

## Elixir

| folder | what it is |
|--------|-----------|
| [`elixir/trigram_counter`](elixir/trigram_counter) | CLI (escript) that prints the 100 most common three-word sequences of a text, read from files or stdin. A take-home task; try it on [*On the Origin of Species*](http://www.gutenberg.org/cache/epub/2009/pg2009.txt). |
| [`elixir/elixir_in_action`](elixir/elixir_in_action) | The to-do server built through *Elixir in Action*: processes, supervision, a pooled file database, distribution. |
| [`elixir/otp_processes`](elixir/otp_processes) | Small apps exploring application startup and running work under a `Task.Supervisor`. |
| [`elixir/elixir_trees`](elixir/elixir_trees) | A binary tree and its traversals. |
| [`elixir/binary_search`](elixir/binary_search) | Binary search with tests. |
| [`elixir/mock_interview`](elixir/mock_interview) | Mock-interview tasks: a word dictionary with `*` wildcard lookups, and a random "secret Santa" pairing. |
| [`elixir/scripts`](elixir/scripts) | One-off scripts. |

## Erlang

| folder | what it is |
|--------|-----------|
| [`erlang/password_manager`](erlang/password_manager) | `passm`: a minimal password manager in pure Erlang (encrypted vault, clipboard daemon, single binary). |
| [`erlang/cowboy_chat`](erlang/cowboy_chat) | A WebSocket chat handler on top of Cowboy. |

## Go

| folder | what it is |
|--------|-----------|
| [`go/payroll_monolith`](go/payroll_monolith) | Prototype of a service-oriented monolith: an API gateway talking to services through an in-memory message broker. |
| [`go/stepik`](go/stepik) | Exercises from a Stepik Go course. |

## Other

| folder | what it is |
|--------|-----------|
| [`cpp`](cpp) | A Monte Carlo simulation of a low-probability item upgrade: average attempts until success and how often long failure streaks happen. |
| [`devops`](devops) | A docker-compose file for an all-in-one Jaeger with OTLP ingestion enabled. |
