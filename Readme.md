# Freshdesk -> GrooveHQ migration
We're moving our tickets from Freshdesk to [GrooveHQ.com](http://www.groovehq.com). This is a set of tools to do the migration.

# Installing
`bundle` to install the gems. That's it, really.


# Rake tasks
The jobs are written in rake tasks but the interface is a cli application, so just type `rake` to get started. You'll be prompted to choose a company and then a task.



# Things you can do
## Show overview
Shows a summary of freshdesk tickets for the client, like this: 
```
+--------+-------+
|Client name     |
+--------+-------+
| Status | Count |
+--------+-------+
| Open   | 4     |
| Closed | 5     |
+--------+-------+
```

## Migrate tickets
If you choose to migrate tickets, you'll be prompted to choose a status (or all) to migrate; it'll run through each ticket and all the associated messages and transfer them.

# Idempotence
The script should be pretty good at checking that a message doesn't already exist, and skip ones which do. The only thing which won't work is migrating new thread items (notes etc.) to Groove if you've already done that thread before.

# Messing around in the cli
If you want to poke around the objects in the cli, run `bundle console` and then load the environment like this:

`load 'config/environment.rb'`

Freshdesk data is in the `Freshdesk` namespace:

```
Freshdesk::Contacts.all.to_a # returns an array of contacts

Freshdesk::Companies.find(123) # returns company 123

Freshdesk::Tickets.where(company_id: 123, per_page: 20, included: :requester) #return the first 20 tickets for company 123, with requester data embedded
```

This library uses the excellent [Her](https://github.com/remiprev/her) gem to do the heavy lifting.

# Known Issues
The biggest issue is that this __won't work for contacts with > 100 tickets__. Freshdesk requires pagination and we haven't got that here.
 
 # License
 MIT. Have fun!