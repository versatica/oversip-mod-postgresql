# oversip-mod-postgresql

## Overview

`oversip-mod-postgresql` provides an easy to use PostgreSQL connector for [OverSIP](http://www.oversip.net) proxy based on [ruby-em-pg-client](https://github.com/royaltm/ruby-em-pg-client) driver (which is based on [ruby-pg](https://bitbucket.org/ged/ruby-pg/wiki/Home)).

`oversip-mod-postgresql` depends on [OverSIP](http://www.oversip.net) >= 1.3.0 which enforces the usage of "sync" style coding via [em-synchrony](https://github.com/igrigorik/em-synchrony/) Gem.

* For more information about `em-synchrony` usage check [Untangling Evented Code with Ruby Fibers](http://www.igvita.com/2010/03/22/untangling-evented-code-with-ruby-fibers/).

Check the [ruby-em-pg-client documentation](https://github.com/royaltm/ruby-em-pg-client/blob/master/README.rdoc) and [ruby-pg documentation](http://deveiate.org/code/pg/) for the exact syntax and usage.


## API


### Method `OverSIP::Modules::Postgresql.add_pool(options)`

Creates a PostgreSQL connection pool by receiving a mandatory `options` (a `Hash`) with the following fields:
* `:pool_name`: Mandatory field. Must be a `Symbol` with the name for this pool.
* `:pool_size`: The number of parallel PostgreSQL connections to perform. By default 10.
* The rest of fields will be passed to each `PG::EM::Client.new` being created (which inherits from [`PG::Connection`](http://deveiate.org/code/pg/PG/Connection.html)).

The method allows passing a block which would be later called by passing as argument each generated `PG::EM::Client` instance.

The created connection pool is an instance of [`EventMachine::Synchrony::ConnectionPool`](https://github.com/igrigorik/em-synchrony/blob/master/lib/em-synchrony/connection_pool.rb).


### Method `OverSIP::Modules::PostgreSQL.pool(pool_name)`

Retrieves a previously created pool with the given name. Raises an `ArgumentError` if the given name does not exist in the list of created pools.



## Usage Example

On top of `/etc/oversip/server.rb`:

```
require "oversip-mod-postgresql"
```


Within the `OverSIP::SipEvents.on_initialize()` method in `/etc/oversip/server.rb`:

```
def (OverSIP::SystemEvents).on_initialize
  OverSIP::M::Postgresql.add_pool({
    :pool_name => :my_db,
    :pool_size => 5,
    :host => "localhost",
    :user => "oversip",
    :password => "xxxxxx",
    :dbname => "oversip"
  }) {|conn| log_info "PostgreSQL created connection: #{conn.inspect}" }
end
```

Somewhere within the `OverSIP::SipEvents.on_request()` method in `/etc/oversip/server.rb`:

```
pool = OverSIP::M::Postgresql.pool(:my_db)

begin
  result = pool.query "SELECT * FROM users WHERE user = \'#{request.from.user}\'"
  log_info "DB query result: #{result.to_a.inspect}"
  if result.any?
    # Add a X-Header with value the 'custom_header' field of the table row:
    request.set_header "X-Header", result.first["custom_header"]
    proxy = ::OverSIP::SIP::Proxy.new :proxy_out
    proxy.route request
    return
  else
    request.reply 404, "User not found in DB"
    return
  end

rescue ::PG::Error => e
  log_error "DB query error:"
  log_error e
  request.reply 500, "DB query error"
  return
end
```

## Notes

* If you want to place a SQL query within an event different than those provided by OverSIP (i.e. within a EventMachine `add_timer` or `next_tick` callback) then you need to create a Fiber and place the SQL query there (otherwise "can't yield from root fiber" error will occur):
```
EM.add_periodic_timer(2) do
  Fiber.new do
    pool = OverSIP::M::Postgresql.pool(:my_db)
    rows = pool.query "SELECT * FROM users"
    log_info "online users: #{rows.inspect}"
  end
end
```


## Dependencies

* Ruby > 1.9.2.
* [oversip](http://www.oversip.net) Gem >= 1.3.0.
* PostgreSQL development library (the package `libpq-dev` in Debian/Ubuntu).


## Installation

```
~$ gem install oversip-mod-postgresql
```


## Author

Iñaki Baz Castillo
* Mail: ibc@aliax.net
* Github profile: [@ibc](https://github.com/ibc)
