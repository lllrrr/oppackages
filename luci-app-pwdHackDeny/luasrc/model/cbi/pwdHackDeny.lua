local fs  = require "nixio.fs"
local sys = require "luci.sys"
local m,s
-- local button = ""
local running=(luci.sys.call("pidof pwdHackDeny.sh > /dev/null") == 0)
local a1=(luci.sys.call("[ `grep -c 'Bad password attempt' /etc/pwdHackDeny/badip.log.ssh 2>/dev/null` -gt 0 ]") == 0)
local b1=(luci.sys.call("[ `grep -c 'failed login on' /etc/pwdHackDeny/badip.log.web 2>/dev/null` -gt 0 ]") == 0)

if running then
	state_msg = "<b><font color=\"green\">" .. translate("正在运行") .. "</font></b>"
else
	state_msg = "<b><font color=\"red\">" .. translate("没有运行") .. "</font></b>"
end
if a1 then
	state_msg1 = "<b><font color=\"red\">" .. translate("有SSH异常登录！") .. "</font></b>"
else
	state_msg1 = "<font color=\"gray\">SSH最近登录日志</font>"
end
if b1 then
	state_msg2 = "<b><font color=\"red\">" .. translate("有WEB异常登录！") .. "</font></b>"
else
	state_msg2 = "<font color=\"gray\">WEB最近登录日志</font>"
end

m = Map("pwdHackDeny", translate("登录管制"))
m.description = translate("监控SSH及WEB异常登录，密码错误累计达到 5 次的内外网客户端都禁止连接SSH以及WEB登录端口，<br>直到手动删除相应的IP或MAC名单为止。也可以在名单中添加排除项目，被排除的客户端将不会被禁止。" .. "<br><br>" .. translate("运行状态 : ") .. state_msg .."<br />")

s = m:section(TypedSection, "pwdHackDeny")
s.anonymous=true
s.addremove=false
--s.template = "cbi/tblsection"

enabled = s:option(Flag, "enabled", translate("启用"), translate(""))
enabled.default = 0
enabled.rmempty = true

setport =s:option(Value,"time",translate("巡查时间（秒）"))
setport.description = translate("")
setport.placeholder=5
setport.default=5
setport.datatype="port"
setport.rmempty=false

setport =s:option(Value,"sum",translate("失败次数（次）"))
setport.description = translate("")
setport.placeholder=5
setport.default=5
setport.datatype="port"
setport.rmempty=false

local aa2=(luci.sys.call("[ `sed -n '$=' /etc/pwdHackDeny/badip.log.ssh 2>/dev/null` -gt 0 ]") == 0)
if aa2 then
	clearsshlog = s:option(Button, "clearsshlog", translate("清除SSH登录日志"))
	clearsshlog.inputtitle = translate("清除")
	clearsshlog.inputstyle = "apply"
	function clearsshlog.write(self, section)
	   luci.sys.exec("cat /dev/null > /etc/pwdHackDeny/badip.log.ssh &")
	   luci.http.redirect(luci.dispatcher.build_url("admin/control/pwdHackDeny"))
	end
end

local bb2=(luci.sys.call("[ -s /etc/pwdHackDeny/badip.log.web ]") == 0)
if bb2 then
	clearlwebog = s:option(Button, "clearlwebog", translate("清除WEB登录日志"))
	clearlwebog.inputtitle = translate("清除")
	clearlwebog.inputstyle = "apply"
	function clearlwebog.write(self, section)
	   luci.sys.exec("cat /dev/null > /etc/pwdHackDeny/badip.log.web &")
	   luci.http.redirect(luci.dispatcher.build_url("admin/control/pwdHackDeny"))
	end
end

s = m:section(TypedSection, "pwdHackDeny")
s.anonymous=true

s:tab("config1", translate(state_msg1))
conf = s:taboption("config1", Value, "editconf1", nil, translate("<font style='color:red'>新的信息需要刷新页面才会显示。如原为启用状态，禁用后又再启用会清除日志显示，但不会清除累积计数。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
conf.readonly="readonly"
--conf:depends("enabled", 1)
function conf.cfgvalue()
	return fs.readfile("/etc/pwdHackDeny/badip.log.ssh", value) or ""
end

s:tab("config2", translate(state_msg2))
conf = s:taboption("config2", Value, "editconf2", nil, translate("<font style='color:red'>新的信息需要刷新页面才会显示。如原为启用状态，禁用后又再启用会清除日志显示，但不会清除累积计数。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
conf.readonly="readonly"
--conf:depends("enabled", 1)
function conf.cfgvalue()
	return fs.readfile("/etc/pwdHackDeny/badip.log.web", value) or ""
end

if (luci.sys.call("[ -s /etc/pwdHackDeny/badhosts.web ] ") == 0) then
	s:tab("config3", translate("<font style='color:brown'>WEB累积记录</font>"))
	conf = s:taboption("config3", Value, "editconf3", nil, translate("<font style='color:red'>新的信息需要刷新页面才会显示。如记录中有自己的MAC，可复制到相应的黑名单中，在前面加#可避免被屏蔽。</font>"))
	conf.template = "cbi/tvalue"
	conf.rows = 20
	conf.wrap = "off"
	conf.readonly="readonly"
	--conf:depends("enabled", 1)
		function conf.cfgvalue()
			return fs.readfile("/etc/pwdHackDeny/badhosts.web", value) or ""
		end
end

if (luci.sys.call("[ -s /etc/pwdHackDeny/badhosts.ssh ] ") == 0) then
	s:tab("config4", translate("<font style='color:brown'>SSH累积记录</font>"))
	conf = s:taboption("config4", Value, "editconf4", nil, translate("<font style='color:red'>新的信息需要刷新页面才会显示。如记录中有自己的MAC，可复制到相应的黑名单中，在前面加#可避免被屏蔽。</font>"))
	conf.template = "cbi/tvalue"
	conf.rows = 20
	conf.wrap = "off"
	conf.readonly="readonly"
	--conf:depends("enabled", 1)
		function conf.cfgvalue()
			return fs.readfile("/etc/pwdHackDeny/badhosts.ssh", value) or ""
		end
end

s:tab("config5", translate("<font style='color:black'>SSH禁止名单</font>"))
conf = s:taboption("config5", Value, "editconf5", nil, translate("<font style='color:red'>预设名单内外网都可以添加IP或MAC地址，IP4段格式为192.168.18.10-20，不能为192.168.1.1/24或192.168.18.10-192.168.18.20。<br>自动拦截的内网名单仅自动添加MAC地址。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/SSHbadip.log") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/SSHbadip.log", value)
        if (luci.sys.call("cmp -s /tmp/SSHbadip.log /etc/SSHbadip.log") == 1) then
            fs.writefile("/etc/SSHbadip.log", value)
        end
        fs.remove("/tmp/SSHbadip.log")
    end
end

s:tab("config6", translate("<font style='color:black'>WEB禁止名单</font>"))
conf = s:taboption("config6", Value, "editconf6", nil, translate("<font style='color:red'>预设名单内外网都可以添加IP或MAC地址，IP4段格式为192.168.18.10-20，不能为192.168.1.1/24或192.168.18.10-192.168.18.20。<br>自动拦截的内网名单仅自动添加MAC地址。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/WEBbadip.log") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/WEBbadip.log", value)
        if (luci.sys.call("cmp -s /tmp/WEBbadip.log /etc/WEBbadip.log") == 1) then
            fs.writefile("/etc/WEBbadip.log", value)
        end
        fs.remove("/tmp/WEBbadip.log")
    end
end

e = luci.http.formvalue("cbi.apply")
if e then
  io.popen("/etc/init.d/pwdHackDeny start")
end

return m
