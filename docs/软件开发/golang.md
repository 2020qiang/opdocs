### goland 开始菜单

```ini
# ${HOME}/.local/share/applications/GoLand.desktop
[Desktop Entry]
Name=GoLand
Exec=/bin/bash -i -c "/opt/GoLand/bin/goland.sh" %f
Icon=/opt/GoLand/bin/goland.png
Terminal=false
Type=Application
Categories=Development;
```





### 获取目录中所有有效的子文件

```golang
func lsDirFiles(dir string) ([]string, error) {
	var files []string
	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && info.Size() > 0 {
			files = append(files, path)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return files, nil
}
```

