module("luci.controller.cowbbonding", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cowbbonding") then
		return
	end
	
	local page

	page = entry({"admin", "network", "cowbbonding"}, cbi("cowbbonding"), "CowB Bonding", 35)
	page.dependent = true
end


