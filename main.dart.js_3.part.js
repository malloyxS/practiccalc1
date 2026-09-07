((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var A,C,B={
aZ_(){return new B.nP(null)},
nP:function nP(d){this.a=d},
GX:function GX(d,e){var _=this
_.d=d
_.e=e
_.r=_.f=$
_.w=!1
_.c=_.a=null},
aua:function aua(d){this.a=d},
au9:function au9(d,e){this.a=d
this.b=e},
aub:function aub(d){this.a=d},
au8:function au8(d,e){this.a=d
this.b=e}},D
A=c[0]
C=c[2]
B=a.updateHolder(c[4],B)
D=c[6]
B.nP.prototype={
a3(){return new B.GX(new A.aZ(null,y.o),new A.bR(C.a3,$.a4()))}}
B.GX.prototype={
bo(){var x,w,v=this
v.di()
if(v.w)return
x=v.c.a0(y.u).f
w=A.aI9(x.b)
w=w==null?null:w.a
v.f=w==null?"USD":w
w=A.aI9(x.c)
w=w==null?null:w.a
v.r=w==null?"RUB":w
v.w=!0},
l(){var x=this.e
x.fr$=$.a4()
x.dy$=0
this.ao()},
a8j(d){var x
if(d==null||C.c.bg(d).length===0)return"\u0412\u0432\u0435\u0434\u0438\u0442\u0435 \u0441\u0443\u043c\u043c\u0443"
x=A.wZ(A.fG(d,",","."))
if(x==null)return"\u042d\u0442\u043e \u043d\u0435 \u0447\u0438\u0441\u043b\u043e"
if(x<0)return"\u0421\u0443\u043c\u043c\u0430 \u043d\u0435 \u043c\u043e\u0436\u0435\u0442 \u0431\u044b\u0442\u044c \u043e\u0442\u0440\u0438\u0446\u0430\u0442\u0435\u043b\u044c\u043d\u043e\u0439"
return null},
A8(){var x=0,w=A.r(y.v),v,u=this,t,s,r,q,p
var $async$A8=A.t(function(d,e){if(d===1)return A.o(e,w)
for(;;)switch(x){case 0:if(!u.d.gL().is()){x=1
break}t=u.c.a0(y.u).f
s=u.f
s===$&&A.a()
r=u.r
r===$&&A.a()
x=3
return A.k(t.qK(s,r),$async$A8)
case 3:if(u.c==null){x=1
break}t=C.c.bg(u.e.a.a)
q=A.fG(t,",",".")
t=u.c
t.toString
s=A.ko(2,u.f,C.a4,!1)
r=A.ko(2,u.r,C.a4,!1)
p=A.ko(2,q,C.a4,!1)
A.az(t).aG("/converter/result?from="+s+"&to="+r+"&amount="+p,null)
case 1:return A.p(v,w)}})
return A.q($async$A8,w)},
G(d){var x,w,v,u,t,s,r,q=this,p=null,o=A.f0(d,"\u041a\u043e\u043d\u0432\u0435\u0440\u0442\u0435\u0440 \u0432\u0430\u043b\u044e\u0442",!0),n=q.f
n===$&&A.a()
x=y.D
w=A.b([],x)
for(v=y.E,u=0;u<6;++u){t=C.lk[u]
s=t.a
w.push(new A.cz(s,A.ab(s+" \u2014 "+t.b,p,p,p,p,p,p),C.aw,p,v))}s=y.w
w=A.vN(D.Jm,n,!1,w,p,new B.aua(q),p,s)
n=q.r
n===$&&A.a()
x=A.b([],x)
for(u=0;u<6;++u){t=C.lk[u]
r=t.a
x.push(new A.cz(r,A.ab(r+" \u2014 "+t.b,p,p,p,p,p,p),C.aw,p,v))}return A.du(o,new A.j6(A.o7(C.c7,A.cL(A.b([w,C.a2,A.vN(D.Jq,n,!1,x,p,new B.aub(q),p,s),C.a2,A.d0(q.e,D.JC,C.U8,1,!1,p,p,q.ga8i()),C.bC,A.hF(!1,D.YW,C.r,p,p,p,p,p,q.galA(),p,p)],y.l),C.bf,C.F,C.a1),q.d),420,p),p,p)}}
var z=a.updateTypes(["j?(j?)","W<~>()"])
B.aua.prototype={
$1(d){var x=this.a
return x.N(new B.au9(x,d))},
$S:75}
B.au9.prototype={
$0(){var x=this.a,w=this.b
if(w==null){w=x.f
w===$&&A.a()}return x.f=w},
$S:0}
B.aub.prototype={
$1(d){var x=this.a
return x.N(new B.au8(x,d))},
$S:75}
B.au8.prototype={
$0(){var x=this.a,w=this.b
if(w==null){w=x.r
w===$&&A.a()}return x.r=w},
$S:0};(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=B.GX.prototype,"ga8i","a8j",0)
w(v,"galA","A8",1)})();(function inheritance(){var x=a.inherit,w=a.inheritMany
x(B.nP,A.T)
x(B.GX,A.Z)
w(A.ky,[B.aua,B.aub])
w(A.vm,[B.au9,B.au8])})()
A.aLS(b.typeUniverse,JSON.parse('{"nP":{"T":[],"e":[]},"GX":{"Z":["nP"]}}'))
var y={E:A.al("cz<j>"),D:A.al("A<cz<j>>"),l:A.al("A<e>"),o:A.al("aZ<r4>"),u:A.al("xx"),w:A.al("j"),v:A.al("~")};(function constants(){D.Jm=new A.bZ(null,null,null,"\u0418\u0437 \u0432\u0430\u043b\u044e\u0442\u044b",null,null,null,null,null,null,null,null,null,null,null,null,!0,!0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,C.R,!0,null,null,null,null)
D.Jq=new A.bZ(null,null,null,"\u0412 \u0432\u0430\u043b\u044e\u0442\u0443",null,null,null,null,null,null,null,null,null,null,null,null,!0,!0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,C.R,!0,null,null,null,null)
D.JC=new A.bZ(null,null,null,"\u0421\u0443\u043c\u043c\u0430",null,null,null,null,null,null,null,null,null,null,null,null,!0,!0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,C.R,!0,null,null,null,null)
D.YW=new A.b3("\u041a\u043e\u043d\u0432\u0435\u0440\u0442\u0438\u0440\u043e\u0432\u0430\u0442\u044c",null,null,null,null,null,null,null,null)})()};
(a=>{a["8zx4L61mLpGgkFj+RVbFySvw3as="]=a.current})($__dart_deferred_initializers__);