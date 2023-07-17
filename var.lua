local var = {}

var.args = {}
var.state = "normal"
var.state_text = {normal = "Normal", text = "Insert", visual = "Visual"}

var.getstate = function()
	return var.state
end

return var
