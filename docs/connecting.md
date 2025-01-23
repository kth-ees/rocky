The connections to the server are established using SSH tunnels and then routing the VNC traffic through the tunnel. This is done to ensure that the connection is secure 
and that the VNC traffic is encrypted.

To connect to the servers, you need to have an SSH key. If you don't have one, follow the instructions [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).

Submit your **public** SSH key to the course assistant and wait for the accounts to be created.

**Make sure you don't submit your private key or the key sianture or any other sensitive information. Only the public key is needed.**

Once your account is created, consult the username and port that you have been assigned. It will be published in **Files**  or sent to you once the accounts are created.

To access the servers, you need an SSH and a VNC client. We recommend [TigerVNC](https://tigervnc.org/). Follow the installation according to your OS. You don't need to install the server; only the VNC viewer is sufficient. SSH clients should come with most of the modern OS already; if you use an old Windows version, follow [this](https://learn.microsoft.com/en-us/windows/terminal/tutorials/ssh) instructions.

To connect, first establish a tunnel to your account and port. The account username and port are individual and can be found in **Files**

```bash
ssh -L 5901:localhost:5901 -p PORT USERNAME@ekurs1.eecs.kth.se
```

Replace **USERNAME** and **PORT** accordingly. Note that the server can be different, depending on the course or project
you are working on.

After the tunnel is established, open VNC viewer and connect to `localhost:1`

![image](https://github.com/user-attachments/assets/858c38a6-495e-470b-98a3-07ed2fce197e)

You should now be logged in to your server account.

To access the tools, open a terminal and run:

```bash
module use /opt/tools/modules/
```

Now, by running `module avail`, you will see which tools you have available. You can try to start ModelSim by running

```bash
module add questa
vsim&
```

You can add the `module use` line in your `.bashrc` so you won't have to run it every time.

When using VNC, **do not logout**. This will cause the VNC server to crash. If you accidentally log out, run the following commands to restart the VNC server:

```bash
pkill Xvnc
pkill vncserver
vncserver :1 -SecurityTypes None
```

### Accessing files on the server

To access files on the server you have several options:

- Using the browser inside the server session to download files
- Using an SFTP client, such as [FileZilla](https://filezilla-project.org/)
- Using commands like [scp](https://linux.die.net/man/1/scp) or [rsync](https://linux.die.net/man/1/rsync)
- Mounting your server home directory in your local machine using [SSHFS](https://wiki.archlinux.org/title/SSHFS). Versions of SSHFS also exist for [Windows](https://github.com/winfsp/sshfs-win) and [MacOS](https://osxfuse.github.io/)

The most streamline solution is to use SSHFS, since this will allow to edit your files locally using your preferred editor. Some editors like [VS Code have extensions](https://marketplace.visualstudio.com/items?itemName=Kelvin.vscode-sshfs) that integrate SSHFS seamlessly.
````
