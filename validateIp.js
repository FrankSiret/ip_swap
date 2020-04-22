function validateIp(object) {
    var text = object.text
    var x = text.split('.')
    var b = true
    for(var i=0; i<x.length; i++) b &= (x[i] <= 255)
    if(!b) text = text.substring(0,text.length-1)
    return text
}

var c0 = "white"
var c1 = "red"

function isValidIp(obj) {

    obj.animationError.stop()
    var targets = []

    var b = true
    if (obj.ip.length === 0 || f1(obj.ip)) {
        targets.push(obj.t_ip)
        b = false
    }
    else obj.t_ip.color = c0

    if (obj.mask.length === 0 || f1(obj.mask)) {
        targets.push(obj.t_mask)
        b = false
    }
    else obj.t_mask.color = c0

    if (f1(obj.gateway)) {
        targets.push(obj.t_gateway)
        b = false
    }
    else obj.t_gateway.color = c0

    if (f1(obj.dns1)) {
        targets.push(obj.t_dns1)
        b = false
    }
    else obj.t_dns1.color = c0

    if (f1(obj.dns2)) {
        targets.push(obj.t_dns2)
        b = false
    }
    else obj.t_dns2.color = c0

    if(!b) {
        obj.animationErrorInner1.targets = targets
        obj.animationErrorInner2.targets = targets
        obj.animationError.start()
    }

    return b;
}

function f1(text) {
    return text.length > 0 && (text.split(".").length !== 4 || text.charAt(text.length-1) === ".")
}
