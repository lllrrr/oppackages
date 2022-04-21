local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local wan = luci.util.exec("uci get network.wan.ifname")
local lan = luci.util.exec("uci get network.lan.ifname")

-- 开始
m = Map("wifidog", "WifiDog配置")
s = m:section(TypedSection, "wifidog")
s.anonymous = true
s.addremove = false

-- 初始化菜单
s:tab("general", translate("通用配置"))
s:tab("servers", translate("认证配置"))
s:tab("advanced", translate("高级配置"))

-- 通用配置
wifi_enable = s:taboption("general", Flag, "wifidog_enable", translate("启用插件"))

local t = io.popen("ifconfig | grep HWaddr | awk -F\" \" '{print $5}' | awk '$1~//{print;exit}' | sed 's/://g'")
local temp = t:read("*all")
gatewayID = s:taboption("general", Value, "gateway_id", translate("设备号"), "")
gatewayID.default = temp

gateway_interface = s:taboption("general", Value, "gateway_interface", translate("内网接口"), "LAN接口")
gateway_interface.default = "br-lan"
gateway_interface:value(lan, lan .."")

external_interface = s:taboption("general", Value, "external_interface", translate("外网接口"), "WAN接口")
external_interface:value(wan, wan .."")

for _, e in ipairs(sys.net.devices()) do
    if e ~= "lo" then gateway_interface:value(e) end
    if e ~= "lo" then external_interface:value(e) end
end


-- 认证配置
server_hostname = s:taboption("servers", Value, "server_hostname", translate("地址"), "认证服务器的域名或IP")
server_hostname.datatype = 'host'
server_hostname.default = "portal.wifidog.net"

server_httpport = s:taboption("servers", Value, "server_httpport", translate("端口"), "认证服务器的端口")
server_httpport.default = "80"

server_path = s:taboption("servers", Value, "server_path", translate("URL路径"))
server_path.default = "/"

server_sslAvailable = s:taboption("servers", Flag, "server_sslAvailable", translate("SSL"))
server_sslAvailable.default = server_sslAvailable.disabled

server_sslport = s:taboption("servers", Value, "server_sslport", translate("SSL端口"))
server_sslport.default = "443"

server_LoginScriptPathFragment = s:taboption("servers", Value, "server_LoginScriptPathFragment", translate("登陆API"))
server_LoginScriptPathFragment.default = "login?"

server_PortalScriptPathFragment = s:taboption("servers", Value, "server_PortalScriptPathFragment", translate("门户API"))
server_PortalScriptPathFragment.default = "portal?"

server_PingScriptPathFragment = s:taboption("servers", Value, "server_PingScriptPathFragment", translate("心跳API"))
server_PingScriptPathFragment.default = "ping?"

server_AuthScriptPathFragment = s:taboption("servers", Value, "server_AuthScriptPathFragment", translate("授权API"))
server_AuthScriptPathFragment.default = "auth?"

server_MsgScriptPathFragment = s:taboption("servers", Value, "server_MsgScriptPathFragment", translate("消息API"))
server_MsgScriptPathFragment.default = "message?"

-- 高级配置
daemon_enable = s:taboption("advanced", Flag, "daemon_enable", translate("进程守护"))
daemon_enable:depends("wifidog_enable", "1")

gateway_port = s:taboption("advanced", Value, "gateway_port", translate("监听端口"))
gateway_port.default = "2060"

check_interval = s:taboption("advanced", Value, "check_interval", translate("心跳"), "客户端与本机的心跳，单位：秒")
check_interval.default = "60"

client_timeout = s:taboption("advanced", Value, "client_timeout", translate("超时"), "大于[心跳*超时]秒则踢客户端下线")
client_timeout.default = "5"

popular_servers = s:taboption("advanced", Value, "popular_servers", translate("DNS域名"), "用于检测DNS健康程度的域名，以,号分隔")
popular_servers.default = "www.google.com,www.baidu.com"

-- Mac白名单
mac = s:taboption("advanced", DynamicList, "trustedmaclist", translate("Mac白名单"), translate("无需授权即可访问网络"))
mac.datatype = "list(macaddr)"
mac.rmempty = true

luci.ip.neighbors({family = 4}, function(n)
    if n.mac and n.dest then
        mac:value(n.mac, "%s (%s)" %{n.mac, n.dest:string()})
    end
end)

-- 访问白名单
s = m:section(TypedSection, "allowrule", translate("访问白名单"))
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true
s.sortable = false
s.rmempty = true

protocol = s:option(ListValue, "protocol", translate("协议"))
protocol:value('tcp')
protocol:value('udp')
protocol:value('icmp')
protocol.default = "tcp"
protocol.rmempty = false

ip = s:option(Value, "ip", translate("IP"))
ip.datatype = "ip4addr"
ip.rmempty  = true

port = s:option(Value, "port", translate("端口号"))
port.datatype = "port"
port.rmempty = true

return m
