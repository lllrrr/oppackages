# luci-app-wifidog

## 编译
```
git clone https://github.com/Scyllaly/luci-app-wifidog.git
cp -r luci-app-wifidog/ lede/package/feeds/luci/luci-app-wifidog
cd lede/
make menuconfig
LuCI -> Applications -> luci-app-wifidog
```


## 过白&拉黑
参考防火墙配置：https://github.com/wifidog/wifidog-gateway/blob/master/wifidog.conf

vim /etc/wifidog.conf
修改：`FirewallRuleSet global` 部分，例如：

```
FirewallRuleSet global {
    FirewallRule block tcp port 25 #禁止发邮件
    FirewallRule allow tcp to www.facebook.com
    FirewallRule allow tcp to m.facebook.com
    FirewallRule allow tcp to static.xx.fbcdn.net
}
```

## 配置
- `/etc/init.d/wifidog` wifidog启动脚本
- `/etc/init.d/wdctl` wifidog监控脚本
- `/etc/wifidog.conf` wifidog启动时加载的配置文件，保存配置后文件将被覆盖
- `/etc/config/wifidog` luci-app-wifidog保存的配置

## 接口
以6网口x86硬件为例：
- 接口 -> br-lan的物理网口改为：eth0～eth4
- 接口 -> wan和wan6的物理网口改为：eth5
- LAN口设置为：br-lan
- WAN口设置为：eth5
- 网络接入线插在eth5上，AP接在eth0～eth4任意一个网口上
