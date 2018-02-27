# Development Decisions

I dicided that the chain of management should be of one direction. That is a user can only
manages the user whose management level is lower or equals to him. For example, there are
user alice, with manage level 3, bob with manage level 2, and charlie and dan with manage 
level 1. Then, alice can decide to manage or unmanage bob, charlie and dan. Bob, however,
can not manages alice, can decide to manage or unmanage charlie and dan. For the user in same
level of management, once a user who decided to manages the other, the other can not manage back
his manager. For example, if charlie clicked manage button on dan, than dan can not click the manage
button on charlie, even they are at same level. Only when charlie cliked unmanage button on dan, then 
dan can click the manage button on charlie.

On task update page, the task assigner can only edit title, description, and assign to field,
assignee can only edit complete, start time and end time field.

The start time field and end time input filed in task update page is not set to readonly, for user
to manually edit the given time stamp, if the user wish to.

On task show page, which is the page showing the task details, the the task assigner can only view the
task details and timeblocks updated by the assignee. The assignee can view the task details and timeblocks,
and edit or remove timeblocks.

If a manager decide to unmanage a managee, the complete assigned tasks should persists for furture references,
however, the umcomplete tasks will be deleted for assignee, since the assignee is no longer under the management.

# TaskTracker

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
