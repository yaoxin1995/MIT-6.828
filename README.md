# Homework: shell
This assignment will make you more familiar with the Unix system call interface and the shell by implementing several features in a small shell, which we will refer to as the 6.828 shell.

## KEY POINT

### I/O redirection

`echo "6.828 is cool" > x.txt`: A child process of shell execute the program `echo`. But before exec `echo`, the child
first use `close(1)` and `open(x.txt)` to switch the std_output from the shell to the file `x.txt`.

`cat < x.txt`: A child process of shell execute the program `cat`.  But before exec `cat`, the child
first use `close(0)` and `open(x.txt)` to switch the std_input from the shell to the file `x.txt`.

### Pipe

A pipe is a small kernel buffer exposed to processes as a pair of file descriptors, one for reading and one for writing.
Writing data to one end of the pipe makes that data available for reading from the other end of the pipe. 

```
int p[2];
pipe(p);
```

The array p is used to return two file descriptors referring to the ends of the pipe. p[0] refers to the read end of the pipe. p[1] refers to the write end of the pipe.

If no data is available, a read on a pipe waits for either data to be written or all file descriptors referring to the write end to be closed; in the latter case, read will return 0, just as if the end of a data file had been reached.

```
$ ls | sort
```

The child process creates a pipe to connect the
left end of the pipeline with the right end. Then it calls fork and runcmd for the left
end of the pipeline and fork and runcmd for the right end, and waits for both to finish. The right end of the pipeline may be a command that itself includes a pipe (e.g.,
a | b | c), which itself forks two new child processes (one for b and one for c). Thus,
the shell may create a tree of processes. The leaves of this tree are commands and the
interior nodes are processes that wait until the left and right children complete

