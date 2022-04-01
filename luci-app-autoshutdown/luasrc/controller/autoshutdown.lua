module("luci.controller.autoshutdown",package.seeall)
function index()
entry({"admin","system","autoshutdown"},cbi("autoshutdown"),_("Scheduled Reboot"),88)
end
