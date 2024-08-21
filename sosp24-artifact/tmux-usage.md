# tmux Usage

You can easily make your ssh sessions persistent using a tool called `tmux`. It is already installed on the server that we provide.

Before starting the experiments, simply enter the `tmux` command in your terminal window. You can then enter commands as usual.

Now say you're ssh session gets disconnected in the middle of an experiment. Not to worry. Just re-ssh into the server, and enter the following to re-attach to your previous tmux session:
```
tmux attach
```

Your experiment would have continues running even when you were disconnected.

Use `exit` command to exit/destroy a tmux session.
You can list currently active tmux sessions `tmux list-sessions`
To attach to a specific session you can use `tmux attach-session -t <session-id>` (<session-id> is the left most number you see in `tmux list-sessions`)
