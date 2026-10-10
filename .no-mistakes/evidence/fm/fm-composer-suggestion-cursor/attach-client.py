# Attach a real tmux client to the lab session through a pty with a non-zero
# window size so the pane is focused (Claude draws its inverse cursor cell).
import os, pty, sys, time, fcntl, termios, struct, select
lab, secs = sys.argv[1], float(sys.argv[2])
pid, fd = pty.fork()
if pid == 0:
    os.environ["TMUX_TMPDIR"] = lab + "/tmux"; os.environ.pop("TMUX", None)
    os.environ["TERM"] = "xterm-256color"
    os.execvp("tmux", ["tmux", "-L", "fm-lab", "attach", "-t", "primary"])
fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 40, 120, 0, 0))
end = time.time() + secs
while time.time() < end:
    r, _, _ = select.select([fd], [], [], 0.2)
    if r:
        try: os.read(fd, 65536)
        except OSError: break
os.kill(pid, 15)
