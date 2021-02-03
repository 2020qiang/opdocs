package main

import (
    "fmt"
    "syscall"
    "time"
    "unsafe"
)

func windowsInputDeviceIdleTime() time.Duration {
    /*
     * 使用Golang获取Windows输入设备空闲的时间（键盘、鼠标、手柄、等外设）
     * https://stackoverflow.com/questions/22949444/using-golang-to-get-windows-idle-time-getlastinputinfo-or-similar
     */
    var (
        user32           = syscall.MustLoadDLL("user32.dll")
        kernel32         = syscall.MustLoadDLL("kernel32.dll")
        getLastInputInfo = user32.MustFindProc("GetLastInputInfo")
        getTickCount     = kernel32.MustFindProc("GetTickCount")
        lastInputInfo    struct {
            cbSize uint32
            dwTime uint32
        }
    )
    lastInputInfo.cbSize = uint32(unsafe.Sizeof(lastInputInfo))
    currentTickCount, _, _ := getTickCount.Call()
    r1, _, err := getLastInputInfo.Call(uintptr(unsafe.Pointer(&lastInputInfo)))
    if r1 == 0 {
        var msg = "Error: getting last input info"
        if err != nil {
            msg = fmt.Sprintf("%s: %s", msg, err.Error())
        }
        panic(msg)
    }
    return time.Duration(uint32(currentTickCount)-lastInputInfo.dwTime) * time.Millisecond
}

func main() {
    t := time.NewTicker(1 * time.Second)
    for range t.C {
        fmt.Println(windowsInputDeviceIdleTime())
    }
}
