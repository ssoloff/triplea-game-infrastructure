## Infrastructure "role"

Borrowing terms from ansible or puppet, a 'role' is the component type.

In this folder we have the install/update scripts for each specific component type.

The general setup scripts will be run first, control will then flow to the right role
script per server to execute an install or update.
