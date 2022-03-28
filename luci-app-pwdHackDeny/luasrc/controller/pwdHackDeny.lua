module("luci.controller.pwdHackDeny", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/pwdHackDeny") then return end

    entry({"admin", "control"}, firstchild(), "Control", 50).dependent = false
    entry({"admin", "control", "pwdHackDeny"}, cbi("pwdHackDeny"), _("登入管制"), 10).dependent = true
end
