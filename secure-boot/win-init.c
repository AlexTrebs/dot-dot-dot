#include <sys/mount.h>
#include <sys/reboot.h>
#include <sys/wait.h>
#include <unistd.h>

int main(void) {
    mount("proc",     "/proc", "proc",     0, NULL);
    mount("sysfs",    "/sys",  "sysfs",    0, NULL);
    mount("devtmpfs", "/dev",  "devtmpfs", 0, NULL);
    mount("efivarfs", "/sys/firmware/efi/efivars", "efivarfs", 0, NULL);

    pid_t pid = fork();
    if (pid == 0) {
        char *args[] = {"/bin/efibootmgr", "--bootnext", "0000", NULL};
        char *env[]  = {"LD_LIBRARY_PATH=/lib", NULL};
        execve("/bin/efibootmgr", args, env);
        _exit(1);
    }
    waitpid(pid, NULL, 0);
    sync();
    reboot(RB_AUTOBOOT);
    return 0;
}
