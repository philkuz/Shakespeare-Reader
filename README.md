
# Shakespeare Reader
A program that distributes the reading of Shakespeare plays by distributing the reading through erlang processes.

A single director process manages the reading of the Act/Scene titles as well as stage direction. The director also distributes reading to the actor processes by either creating or directing the reading.

All plays come from [shakespeare.mit.edu](shakespeare.mit.edu), chosen because the html formatting is fairly straight forward and therefore easy to parse.
