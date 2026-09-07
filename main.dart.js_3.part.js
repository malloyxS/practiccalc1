((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var A,C,B={
b1q(){return new B.nT(null)},
nT:function nT(d){this.a=d},
HN:function HN(d,e){var _=this
_.d=d
_.e=e
_.r=_.f=$
_.w=!1
_.c=_.a=null},
awk:function awk(d){this.a=d},
awj:function awj(d,e){this.a=d
this.b=e},
awl:function awl(d){this.a=d},
awi:function awi(d,e){this.a=d
this.b=e}},D
A=c[0]
C=c[2]
B=a.updateHolder(c[4],B)
D=c[6]
B.nT.prototype={
a7(){return new B.HN(new A.aT(null,y.o),new A.bZ(C.a5,$.a5()))}}
B.HN.prototype={
bp(){var x,w,v=this
v.du()
if(v.w)return
x=v.c.X(y.u).f
w=A.aL5(x.b)
w=w==null?null:w.a
v.f=w==null?"USD":w
w=A.aL5(x.c)
w=w==null?null:w.a
v.r=w==null?"RUB":w
v.w=!0},
l(){var x=this.e
x.fx$=$.a5()
x.fr$=0
this.an()},
aaB(d){var x
if(d==null||C.c.be(d).length===0)return"\u0412\u0432\u0435\u0434\u0438\u0442\u0435 \u0441\u0443\u043c\u043c\u0443"
x=A.l7(A.fQ(d,",","."))
if(x==null)return"\u042d\u0442\u043e \u043d\u0435 \u0447\u0438\u0441\u043b\u043e"
if(x<0)return"\u0421\u0443\u043c\u043c\u0430 \u043d\u0435 \u043c\u043e\u0436\u0435\u0442 \u0431\u044b\u0442\u044c \u043e\u0442\u0440\u0438\u0446\u0430\u0442\u0435\u043b\u044c\u043d\u043e\u0439"
return null},
AN(){var x=0,w=A.r(y.v),v,u=this,t,s,r,q,p
var $async$AN=A.t(function(d,e){if(d===1)return A.o(e,w)
for(;;)switch(x){case 0:if(!u.d.gM().iB()){x=1
break}t=u.c.X(y.u).f
s=u.f
s===$&&A.a()
r=u.r
r===$&&A.a()
x=3
return A.k(t.re(s,r),$async$AN)
case 3:if(u.c==null){x=1
break}t=C.c.be(u.e.a.a)
q=A.fQ(t,",",".")
t=u.c
t.toString
s=A.kv(2,u.f,C.a7,!1)
r=A.kv(2,u.r,C.a7,!1)
p=A.kv(2,q,C.a7,!1)
A.aC(t).aH("/converter/result?from="+s+"&to="+r+"&amount="+p,null)
case 1:return A.p(v,w)}})
return A.q($async$AN,w)},
F(d){var x,w,v,u,t,s,r,q=this,p=null,o=A.f7(d,"\u041a\u043e\u043d\u0432\u0435\u0440\u0442\u0435\u0440 \u0432\u0430\u043b\u044e\u0442",!0),n=q.f
n===$&&A.a()
x=y.D
w=A.b([],x)
for(v=y.E,u=0;u<6;++u){t=C.lA[u]
s=t.a
w.push(new A.cD(s,A.ad(s+" \u2014 "+t.b,p,p,p,p,p,p),C.aB,p,v))}s=y.w
w=A.wb(D.K_,n,!1,w,p,new B.awk(q),p,s)
n=q.r
n===$&&A.a()
x=A.b([],x)
for(u=0;u<6;++u){t=C.lA[u]
r=t.a
x.push(new A.cD(r,A.ad(r+" \u2014 "+t.b,p,p,p,p,p,p),C.aB,p,v))}return A.dA(o,new A.jg(A.oa(C.cb,A.cN(A.b([w,C.a3,A.wb(D.JG,n,!1,x,p,new B.awl(q),p,s),C.a3,A.d3(q.e,D.JZ,C.UY,1,!1,p,p,q.gaaA()),C.bH,A.hM(D.ZN,q.gaoq())],y.l),C.bm,C.G,C.a2),q.d),420,p),p,p)}}
var z=a.updateTypes(["j?(j?)","Y<~>()"])
B.awk.prototype={
$1(d){var x=this.a
return x.N(new B.awj(x,d))},
$S:69}
B.awj.prototype={
$0(){var x=this.a,w=this.b
if(w==null){w=x.f
w===$&&A.a()}return x.f=w},
$S:0}
B.awl.prototype={
$1(d){var x=this.a
return x.N(new B.awi(x,d))},
$S:69}
B.awi.prototype={
$0(){var x=this.a,w=this.b
if(w==null){w=x.r
w===$&&A.a()}return x.r=w},
$S:0};(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=B.HN.prototype,"gaaA","aaB",0)
w(v,"gaoq","AN",1)})();(function inheritance(){var x=a.inherit,w=a.inheritMany
x(B.nT,A.T)
x(B.HN,A.Z)
w(A.kE,[B.awk,B.awl])
w(A.vO,[B.awj,B.awi])})()
A.aOV(b.typeUniverse,JSON.parse('{"nT":{"T":[],"e":[]},"HN":{"Z":["nT"]}}'))
var y={E:A.al("cD<j>"),D:A.al("A<cD<j>>"),l:A.al("A<e>"),o:A.al("aT<rl>"),u:A.al("y_"),w:A.al("j"),v:A.al("~")};(function constants(){D.JG=new A.c7(null,null,null,"\u0412 \u0432\u0430\u043b\u044e\u0442\u0443",null,null,null,null,null,null,null,null,null,null,null,null,!0,!0,!1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,C.T,!0,null,null,null,null)
D.JZ=new A.c7(null,null,null,"\u0421\u0443\u043c\u043c\u0430",null,null,null,null,null,null,null,null,null,null,null,null,!0,!0,!1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,C.T,!0,null,null,null,null)
D.K_=new A.c7(null,null,null,"\u0418\u0437 \u0432\u0430\u043b\u044e\u0442\u044b",null,null,null,null,null,null,null,null,null,null,null,null,!0,!0,!1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,C.T,!0,null,null,null,null)
D.ZN=new A.b7("\u041a\u043e\u043d\u0432\u0435\u0440\u0442\u0438\u0440\u043e\u0432\u0430\u0442\u044c",null,null,null,null,null,null,null,null)})()};
(a=>{a["M9X+y87hfmNijywqcz2yMfNYlWI="]=a.current})($__dart_deferred_initializers__);