package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"syscall"
)

// docker         run <image> <cmd> <params>
// go run main.go run         <cmd> <params>

func main() {
	switch os.Args[1] {
	case "run":
		run()
	case "child":
		child()
	default:
		panic("HELLPP!!!")

	}

}

func run() {
	fmt.Printf("Running %v as PID: %d\n", os.Args[2:], os.Getpid())
	cmd := exec.Command("/proc/self/exe", append([]string{"child"}, os.Args[2:]...)...)
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout

	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags:   syscall.CLONE_NEWUTS | syscall.CLONE_NEWPID | syscall.CLONE_NEWNS,
		Unshareflags: syscall.CLONE_NEWNS,
	}

	handleError(cmd.Run())
}

func child() {
	fmt.Printf("Running %v as PID: %d\n", os.Args[2:], os.Getpid())
	cg()
	cmd := exec.Command(os.Args[2], os.Args[3:]...)
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	syscall.Chroot("/mnt/c/Users/PavelMalinov/ubuntu")
	syscall.Chdir("/")
	syscall.Mount("proc", "proc", "proc", 0, "")

	handleError(syscall.Sethostname([]byte("Techtalk")))

	handleError(cmd.Run())
	syscall.Unmount("proc", 0)
}

func cg() {
	cgroups := "/sys/fs/cgroup/"
	pids := filepath.Join(cgroups, "pids")
	os.Mkdir(filepath.Join(pids, "pavel"), 0755)
	handleError(ioutil.WriteFile(filepath.Join(pids, "pavel/pids.max"), []byte("20"), 0700))
	// Removes the new cgroup in place after the container exits
	handleError(ioutil.WriteFile(filepath.Join(pids, "pavel/notify_on_release"), []byte("1"), 0700))
	handleError(ioutil.WriteFile(filepath.Join(pids, "pavel/cgroup.procs"), []byte(strconv.Itoa(os.Getpid())), 0700))
}

func handleError(err error) {
	if err != nil {
		panic(err)
	}
}
