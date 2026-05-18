window.__require = function t(e, r, o) {
function n(p, s) {
if (!r[p]) {
if (!e[p]) {
var c = p.split("/");
c = c[c.length - 1];
if (!e[c]) {
var a = "function" == typeof __require && __require;
if (!s && a) return a(c, !0);
if (i) return i(c, !0);
throw new Error("Cannot find module '" + p + "'");
}
p = c;
}
var u = r[p] = {
exports: {}
};
e[p][0].call(u.exports, function(t) {
return n(e[p][1][t] || t);
}, u, u.exports, t, e, r, o);
}
return r[p].exports;
}
for (var i = "function" == typeof __require && __require, p = 0; p < o.length; p++) n(o[p]);
return n;
}({
mask_test: [ function(t, e, r) {
"use strict";
cc._RF.push(e, "0762fKl2CJIV6Yn65c5ufVM", "mask_test");
var o, n = this && this.__extends || (o = function(t, e) {
return (o = Object.setPrototypeOf || {
__proto__: []
} instanceof Array && function(t, e) {
t.__proto__ = e;
} || function(t, e) {
for (var r in e) Object.prototype.hasOwnProperty.call(e, r) && (t[r] = e[r]);
})(t, e);
}, function(t, e) {
o(t, e);
function r() {
this.constructor = t;
}
t.prototype = null === e ? Object.create(e) : (r.prototype = e.prototype, new r());
}), i = this && this.__decorate || function(t, e, r, o) {
var n, i = arguments.length, p = i < 3 ? e : null === o ? o = Object.getOwnPropertyDescriptor(e, r) : o;
if ("object" == typeof Reflect && "function" == typeof Reflect.decorate) p = Reflect.decorate(t, e, r, o); else for (var s = t.length - 1; s >= 0; s--) (n = t[s]) && (p = (i < 3 ? n(p) : i > 3 ? n(e, r, p) : n(e, r)) || p);
return i > 3 && p && Object.defineProperty(e, r, p), p;
};
Object.defineProperty(r, "__esModule", {
value: !0
});
var p = cc._decorator, s = p.ccclass, c = p.property, a = function(t) {
n(e, t);
function e() {
var e = null !== t && t.apply(this, arguments) || this;
e.mask_node = null;
e.invert = !1;
e.over_invert = !1;
return e;
}
e.prototype.onLoad = function() {
var t = this.mask_node;
t.active = !1;
var e = this.node.width, r = this.node.height, o = e / t.width, n = r / t.height, i = Math.abs(t.x / e), p = Math.abs(t.y / r), s = this.node.getComponent(cc.Sprite).getMaterial(0);
s.setProperty("x_mul", o);
s.setProperty("y_mul", n);
s.setProperty("x_offset", i);
s.setProperty("y_offset", p);
s.setProperty("invert", this.invert);
s.setProperty("over_invert", this.over_invert);
s.setProperty("mask_a", this.mask_node.opacity / 255);
s.setProperty("texture_mask", t.getComponent(cc.Sprite).spriteFrame.getTexture());
};
e.prototype.start = function() {};
i([ c(cc.Node) ], e.prototype, "mask_node", void 0);
i([ c({
displayName: "遮罩是否反向",
tooltip: "tips"
}) ], e.prototype, "invert", void 0);
i([ c({
displayName: "超出区域是否显示",
tooltip: "tips"
}) ], e.prototype, "over_invert", void 0);
return i([ s ], e);
}(cc.Component);
r.default = a;
cc._RF.pop();
}, {} ]
}, {}, [ "mask_test" ]);