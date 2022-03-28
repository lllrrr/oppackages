local fs  = require "nixio.fs"
local sys = require "luci.sys"
local wa = require "luci.tools.webadmin"
local ipc = require "luci.ip"
local net = require "luci.model.network".init()
local ifaces = sys.net:devices()
local button = ""
local state_msg = ""

local enb=(luci.sys.call("[ $(uci get cowbbonding.cowbbonding.enabled 2>/dev/null) == 1 ] 2>/dev/null") == 0)
local ddd=(luci.sys.call("[ `cat /etc/config/cowbbonding 2>/dev/null|grep -c 'option macwhitelist .1.'` == 1 ] ") == 0)
local ath=(luci.sys.call("[ `cat /usr/bin/77756C6973687569 2>/dev/null|grep -c 'wulishui'` == 2 ] ") == 0)
if ddd then
local aaa=(luci.sys.call("[ `iptables -L FORWARD|grep -c '^cowbbonding' 2>/dev/null` -gt 0 ]") == 0)
local bbb=(luci.sys.call("[ `iptables -L cowbbonding 2>/dev/null|grep -c 'cowbbonding' 2>/dev/null` -gt 0 ] ") == 0)
local ccc=(luci.sys.call("pidof cowbbonding.sh >/dev/null 2>&1") == 0)
if aaa then
        state_msg1 = "<b><font color=\"green\">" .. translate(" 主链✓") .. "</font></b>"
else
        state_msg1 = "<b><font color=\"red\">" .. translate(" 主链不存在") .. "</font></b>"
end
if bbb then
        state_msg2 = "<b><font color=\"green\">" .. translate(" 跳链✓") .. "</font></b>"
else
        state_msg2 = "<b><font color=\"red\">" .. translate(" 跳链不存在") .. "</font></b>"
end
if ccc then
        state_msg3 = "<b><font color=\"green\">" .. translate(" 后台进程✓") .. "</font></b>"
else
        state_msg3 = "<b><font color=\"red\">" .. translate(" 后台未运行") .. "</font></b>"
end
end

m = Map("cowbbonding", translate("CowB绑定"))
m.description = translate("<b><font color=\"green\">CowB绑定可方便用于一次性绑定大量静态DHCP、ARP名单而无须逐条手动输入。你可以使用EXCEL生成MAC对应的IP地址列表或直接从原DHCP分配记录复制过来不加处理即可直接使用。</font></b>")
if ddd and enb then
local s = m:section(TypedSection, "cowbbonding", "")
s.description = translate("").. button .. "" .. translate("白名单状态").. " : "  .. state_msg1 .. translate(" -|-") .. state_msg2 .. translate(" -|-") .. state_msg3 .. ""
s.anonymous = true
end

local s = m:section(TypedSection, "cowbbonding", "")
s.anonymous = true
local e = s:option(Flag, "enabled", translate("启用"), "当使用模式“1”时因DHCP无须每次开机绑定所以每次应用后会自动关闭。")
e.rmempty = false

enabled = s:option(ListValue, "work_mode", translate("绑定模式"))
enabled.description = translate("*如只绑定静态ARP则DHCP有可能会分配与ARP绑定结果不同的IP地址造成混乱。")
enabled:value("1", translate("1.只绑定静态DHCP"))
enabled:value("2", translate("2.同时绑定静态DHCP与静态ARP"))
enabled:value("3", translate("3.只绑定静态ARP"))
enabled.default = 1

e = s:option(Value, "interface", translate("ARP绑定接口"), translate("用于所有内网接口则选择br-lan，用于单一接口则选其他如eth0。"))
e:depends("work_mode", 2)
e:depends("work_mode", 3)
for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		e:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
e.default = "br-lan"
e.rmempty = true

setport =s:option(Value,"leasetime",translate("DHCP租期"))
setport.description = translate("如为纯数字，则为分钟；如数字加h，则为小时；如数字加d，则为天；如填 0 或infinite则为永久。")
setport.placeholder=0
setport.default=0
setport.rmempty=true

if ath then
local e = s:option(Flag, "macwhitelist", translate("<font color=\"red\">联网白名单</font>"), "")
e.description = translate("不允许未经静态MAC-IP绑定的主机联网。")
e:depends("work_mode", 2)
e.rmempty = true

-------------
s = m:section(TypedSection,  "manual",  translate(""),translate("<b><font color=\"black\">手工添加 </font></b>正常填写的名单，在按下“保存并应用”后会被添加到下方编辑框名单的末尾，同时这里会被清空。其中“主机名”、“DUID”、“IPV6后缀”如不需要可以留空。"))
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true

name = s:option(Value, "hostname", translate("Hostname"))
name.datatype = "hostname('strict')"
name.rmempty  = true
function name.write(self, section, value)
	Value.write(self, section, value)
	m:set(section, "dns", "1")
end
function name.remove(self, section)
	Value.remove(self, section)
	m:del(section, "dns")
end

mac = s:option(Value, "MAC", translate("<abbr title=\"Media Access Control\">MAC</abbr>-Address"))
mac.datatype = "list(macaddr)"
mac.rmempty  = true
function mac.cfgvalue(self, section)
	local val = Value.cfgvalue(self, section)
	return ipc.checkmac(val) or val
end

ip = s:option(Value, "IP", translate("<abbr title=\"Internet Protocol Version 4\">IPv4</abbr>-Address"))
ip.datatype = "or(ip4addr,'ignore')"

duid = s:option(Value, "duid", translate("<abbr title=\"The DHCP Unique Identifier\">DUID</abbr>"))
duid.datatype = "and(rangelength(20,36),hexstring)"
fp = io.open("/var/hosts/odhcpd")
if fp then
	for line in fp:lines() do
		local net_val, duid_val = string.match(line, "# (%S+)%s+(%S+)")
		if duid_val then
			duid:value(duid_val, duid_val)
		end
	end
	fp:close()
end

hostid = s:option(Value, "hostid", translate("<abbr title=\"Internet Protocol Version 6\">IPv6</abbr>-Suffix (hex)"))
sys.net.host_hints(function(m, v4, v6, name)
	if m and v4 then
		ip:value(v4)
		mac:value(m, "%s (%s)" %{ m, name or v4 })
	end
end)
function ip.validate(self, value, section)
	local m = mac:formvalue(section) or ""
	local n = name:formvalue(section) or ""
	if value and #n == 0 and #m == 0 then
		return nil, translate("One of hostname or mac address must be specified!")
	end
	return Value.validate(self, value, section)
end
end
------------

s = m:section(TypedSection, "cowbbonding")
s.anonymous=true

o = s:option(TextValue, "/etc/cowbbonding/list.cfg", translate(""), translate("所需内容可智能识别，无须在意先后顺序，只需每行存在一个MAC、IP、IPV6前缀(可无)、DUID(可无)、hostname(可无)，之间由空格隔开。IPV6后缀、DUID仅在定制版固件可用。</br>* Hostname命名规范：只能由a-z A-Z 0-9和符号.-_构成，词首只能为字母，符号不能在末尾，如：Alice.-_PC2 。</br>* IPV6后缀可识别格式为： :ABCD ，必须是完整4位（前加 : ），不能使用缩写法，比如 :0001不能写为 :1。</br>* DUID可识别格式为：0001000123511717fc2d307f010e (28位)或 01-02-03-04-05-06-07-08-09-10-11-12-13-14 (微软格式)。"))
o.rows = 30
o.wrap = "off"
function o.cfgvalue(self, section)
    return fs.readfile("/etc/cowbbonding/list.cfg") or ""
end

function o.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/list.cfg", value)
        if (luci.sys.call("cmp -s /tmp/list.cfg /etc/cowbbonding/list.cfg") == 1) then
            fs.writefile("/etc/cowbbonding/list.cfg", value)
        end
        fs.remove("/tmp/list.cfg")
    end
end

e = luci.http.formvalue("cbi.apply")
if e then
io.popen("/etc/init.d/cowbbonding start")
end

return m


