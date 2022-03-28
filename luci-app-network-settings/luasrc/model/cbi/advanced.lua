m = Map("advanced", translate("快捷设置"), translate("<br><font color=\"Red\"><strong>配置文件是直接编辑保存的！除非你知道在干什么，否则请不要修改这些配置文件。配置不正确可能会导致不能开机，联网等错误。</strong></font><br/><b><font color=\"green\">注释行在行首添加 ＃ 。修改行前建议先备份行再修改。</font></b><br>"))
m.apply_on_parse = true
s = m:section(TypedSection,"advanced")
s.anonymous = true

if nixio.fs.access("/etc/config/network") then
	s:tab("netwrokconf", translate("网络"), translate("本页是/etc/config/network的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	o = s:taboption("netwrokconf", Button, "_network")
	o.inputtitle = translate("重启网络")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/network restart >/dev/null &")
	end

	conf = s:taboption("netwrokconf", Value, "netwrokconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/config/network") or ""
	end
	function conf.write(self, section, value)
		if value then
			value = value:gsub("\r\n?", "\n")
			nixio.fs.writefile("/tmp/network", value)
				if (luci.sys.call("cmp -s /tmp/network /etc/config/network") == 1) then
					nixio.fs.writefile("/etc/config/network", value)
					luci.sys.call("/etc/init.d/network restart >/dev/null &")
				end
			nixio.fs.remove("/tmp/network")
		end
	end
end

if nixio.fs.access("/etc/config/wireless") then
	s:tab("wirelessconf", translate("无线"), translate("本页是/etc/config/wireless的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	o = s:taboption("wirelessconf", Button, "_wifi")
	o.inputtitle = translate("重启wifi")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("wifi reload >/dev/null &")
	end

	conf = s:taboption("wirelessconf", Value, "wirelessconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/config/wireless") or ""
	end

	function conf.write(self, section, value)
		if value then
			value = value:gsub("\r\n?", "\n")
			nixio.fs.writefile("/tmp/wireless", value)
				if (luci.sys.call("cmp -s /tmp/wireless /etc/config/wireless") == 1) then
					nixio.fs.writefile("/etc/config/wireless", value)
					luci.sys.call("wifi reload >/dev/null &")
				end
			nixio.fs.remove("/tmp/wireless")
		end
	end
end

if nixio.fs.access("/etc/config/dhcp") then
	s:tab("dhcpconf", translate("DHCP"), translate("本页是/etc/config/dhcp的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	o = s:taboption("dhcpconf", Button, "_dhcp")
	o.inputtitle = translate("重启dhcp")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/dnsmasq reload >/dev/null &")
	end

	conf = s:taboption("dhcpconf", Value, "dhcpconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/config/dhcp") or ""
	end
	function conf.write(self, section, value)
		if value then
			value = value:gsub("\r\n?", "\n")
			nixio.fs.writefile("/tmp/dhcp", value)
				if (luci.sys.call("cmp -s /tmp/dhcp /etc/config/dhcp") == 1) then
					nixio.fs.writefile("/etc/config/dhcp", value)
					luci.sys.call("/etc/init.d/dnsmasq reload >/dev/null &")
				end
			nixio.fs.remove("/tmp/dhcp")
		end
	end
end

if nixio.fs.access("/etc/config/firewall") then
	s:tab("firewallconf", translate("防火墙"), translate("本页是/etc/config/firewall的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	o = s:taboption("firewallconf", Button, "_firewall")
	o.inputtitle = translate("重启防火墙")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/firewall reload >/dev/null &")
	end

	conf = s:taboption("firewallconf", Value, "firewallconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/config/firewall") or ""
	end
	function conf.write(self, section, value)
		if value then
		value = value:gsub("\r\n?", "\n")
		nixio.fs.writefile("/tmp/firewall", value)
			if (luci.sys.call("cmp -s /tmp/firewall /etc/config/firewall") == 1) then
				nixio.fs.writefile("/etc/config/firewall", value)
				luci.sys.call("/etc/init.d/firewall reload >/dev/null &")
			end
		nixio.fs.remove("/tmp/firewall")
		end
	end
end

if nixio.fs.access("/etc/config/uhttpd") then
	s:tab("uhttpdconf", translate("uhttpd服务器"),translate("本页是/etc/config/uhttpd的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	o = s:taboption("uhttpdconf", Button, "_uhttpd")
	o.inputtitle = translate("重启uhttpd")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/uhttpd restart >/dev/null &")
	end

	conf = s:taboption("uhttpdconf", Value, "uhttpdconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/config/uhttpd") or ""
	end
	function conf.write(self, section, value)
		if value then
			value = value:gsub("\r\n?", "\n")
			nixio.fs.writefile("/tmp/uhttpd", value)
				if (luci.sys.call("cmp -s /tmp/uhttpd /etc/config/uhttpd") == 1) then
					nixio.fs.writefile("/etc/config/uhttpd", value)
					luci.sys.call("/etc/init.d/uhttpd restart >/dev/null &")
				end
			nixio.fs.remove("/tmp/uhttpd")
		end
	end
end

if nixio.fs.access("/etc/config/mwan3") then
	s:tab("mwan3conf", translate("mwan3"), translate("本页是/etc/config/mwan3的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	o = s:taboption("mwan3conf", Button, "_mwan3")
	o.inputtitle = translate("重启mwan3")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/mwan3 restart >/dev/null &")
	end

	conf = s:taboption("mwan3conf", Value, "mwan3conf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/config/mwan3") or ""
	end
	function conf.write(self, section, value)
		if value then
		value = value:gsub("\r\n?", "\n")
		nixio.fs.writefile("/tmp/mwan3", value)
			if (luci.sys.call("cmp -s /tmp/mwan3 /etc/config/mwan3") == 1) then
				nixio.fs.writefile("/etc/config/mwan3", value)
			end
		nixio.fs.remove("/tmp/mwan3")
		end
	end
end

if nixio.fs.access("/etc/hosts") then
	s:tab("hostsconf", translate("hosts"), translate("本页是/etc/hosts的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	o = s:taboption("hostsconf", Button, "_hosts")
	o.inputtitle = translate("重启dnsmasq")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/dnsmasq reload >/dev/null &")
	end

	conf = s:taboption("hostsconf", Value, "hostsconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/hosts") or ""
	end
	function conf.write(self, section, value)
		if value then
		value = value:gsub("\r\n?", "\n")
		nixio.fs.writefile("/tmp/hosts.tmp", value)
			if (luci.sys.call("cmp -s /tmp/hosts.tmp /etc/hosts") == 1) then
				nixio.fs.writefile("/etc/hosts", value)
				luci.sys.call("/etc/init.d/dnsmasq reload >/dev/null &")
			end
		nixio.fs.remove("/tmp/hosts.tmp")
		end
	end
end

if nixio.fs.access("/etc/pcap-dnsproxy/Config.conf") then
	s:tab("pcapconf", translate("pcap-dnsproxy"), translate("本页是/etc/pcap-dnsproxy/Config.conf的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	conf = s:taboption("pcapconf", Value, "pcapconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/pcap-dnsproxy/Config.conf") or ""
	end

	function conf.write(self, section, value)
		if value then
		value = value:gsub("\r\n?", "\n")
		nixio.fs.writefile("/tmp/Config.conf", value)
			if (luci.sys.call("cmp -s /tmp/Config.conf /etc/pcap-dnsproxy/Config.conf") == 1) then
				nixio.fs.writefile("/etc/pcap-dnsproxy/Config.conf", value)
				luci.sys.call("/etc/init.d/pcap-dnsproxy restart >/dev/null &")
			end
		nixio.fs.remove("/tmp/Config.conf")
		end
	end
end

if nixio.fs.access("/etc/dnsmasq.conf") then
	s:tab("dnsmasqconf", translate("dnsmasq"), translate("本页是/etc/dnsmasq.conf的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	o = s:taboption("dnsmasqconf", Button, "_dnsmasq")
	o.inputtitle = translate("重启dnsmasq")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/dnsmasq restart >/dev/null &")
	end

	conf = s:taboption("dnsmasqconf", Value, "dnsmasqconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/dnsmasq.conf") or ""
	end
	function conf.write(self, section, value)
		if value then
		value = value:gsub("\r\n?", "\n")
		nixio.fs.writefile("/tmp/dnsmasq.conf", value)
			if (luci.sys.call("cmp -s /tmp/dnsmasq.conf /etc/dnsmasq.conf") == 1) then
				nixio.fs.writefile("/etc/dnsmasq.conf", value)
				luci.sys.exec("/etc/init.d/dnsmasq reload >/dev/null &")
			end
		nixio.fs.remove("/tmp/dnsmasq.conf")
		end
	end
end

--profile
if nixio.fs.access("/etc/profile") then
	s:tab("profileconf", translate("环境变量"),translate("本页是/etc/profile的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效。<br>"))
	conf = s:taboption("profileconf", Value, "profileconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/profile") or ""
	end
	function conf.write(self, section, value)
		if value then
			value = value:gsub("\r\n?", "\n")
			nixio.fs.writefile("/tmp/profile", value)
			if (luci.sys.call("cmp -s /tmp/profile /etc/profile") == 1) then
				nixio.fs.writefile("/etc/profile", value)
			end
			nixio.fs.remove("/tmp/profile")
		end
	end
end

--rc.local
if nixio.fs.access("/etc/rc.local") then
	s:tab("rc_localconf", translate("本地启动脚本"),translate("本页是/etc/rc.local的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效。<br>启动脚本插入到 'exit 0' 之前即可随系统启动运行。<br>"))
	conf = s:taboption("rc_localconf", Value, "rc_localconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/rc.local") or ""
	end
	function conf.write(self, section, value)
		if value then
			value = value:gsub("\r\n?", "\n")
			nixio.fs.writefile("/tmp/rc.local", value)
			if (luci.sys.call("cmp -s /tmp/rc.local /etc/rc.local") == 1) then
				nixio.fs.writefile("/etc/rc.local", value)
			end
			nixio.fs.remove("/tmp/rc.local")
		end
	end
end

--sysctl.conf
if nixio.fs.access("/etc/sysctl.conf") then
	s:tab("sysctlconf", translate("sysctl内核"),translate("本页是/etc/sysctl.conf的配置文件内容，编辑后点击<code>保存&应用</code>按钮后生效<br>"))
	conf = s:taboption("sysctlconf", Value, "sysctlconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 22
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/sysctl.conf") or ""
	end
	function conf.write(self, section, value)
		if value then
			value = value:gsub("\r\n?", "\n")
			nixio.fs.writefile("/tmp/sysctl.conf", value)
			if (luci.sys.call("cmp -s /tmp/sysctl.conf /etc/sysctl.conf") == 1) then
				nixio.fs.writefile("/etc/sysctl.conf", value)
				luci.sys.call("/sbin/sysctl -p >/dev/null &")
			end
			nixio.fs.remove("/tmp/sysctl.conf")
		end
	end
end

-- if nixio.fs.access("/bin/nuc") then
	-- s:tab("mode", translate("模式切换(适用软路由）"), translate("<br />可以在这里切换NUC和正常模式，重置你的网络设置。<br /><font color=\"Red\"><strong>点击后会立即重启设备，没有确认过程，请谨慎操作！</strong></font><br/>"))
	-- o = s:taboption("mode", Button, "nucmode", translate("切换为NUC模式"), translate("<font color=\"green\"><strong>本模式适合于单网口主机，如NUC、单网口电脑，需要配合VLAN交换机使用！<br />默认gateway是：192.168.2.1，ipaddr是192.168.2.150。用本机接口LAN接上级LAN当NAS。</strong></font><br/>"))
	-- o.inputtitle = translate("NUC模式")
	-- o.inputstyle="reload"

	-- o.write=function()
		-- luci.sys.call("/bin/nuc")
	-- end

	-- o = s:taboption("mode", Button, "normalmode", translate("切换成正常模式"), translate("<font color=\"green\"><strong>本模式适合于有两个网口或以上的设备使用，如多网口软路由或者虚拟了两个以上网口的虚拟机使用！</strong></font><br/>"))
	-- o.inputtitle = translate("正常模式")
	-- o.inputstyle="reload"

	-- o.write = function()
		-- luci.sys.call("/bin/normalmode")
	-- end
-- end

return m
