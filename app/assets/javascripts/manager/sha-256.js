(function() {/*
 A JavaScript implementation of the SHA family of hashes, as defined in FIPS
 PUB 180-2 as well as the corresponding HMAC implementation as defined in
 FIPS PUB 198a

 Copyright Brian Turek 2008-2012
 Distributed under the BSD License
 See http://caligatio.github.com/jsSHA/ for more information

 Several functions taken from Paul Johnson
 */
    function n(a){throw a;}var r=null;function t(a,b){var c=[],f=(1<<b)-1,d=a.length*b,e;for(e=0;e<d;e+=b)c[e>>>5]|=(a.charCodeAt(e/b)&f)<<32-b-e%32;return{value:c,binLen:d}}function w(a){var b=[],c=a.length,f,d;0!==c%2&&n("String of HEX type must be in byte increments");for(f=0;f<c;f+=2)d=parseInt(a.substr(f,2),16),isNaN(d)&&n("String of HEX type contains invalid characters"),b[f>>>3]|=d<<24-4*(f%8);return{value:b,binLen:4*c}}
    function A(a){var b=[],c=0,f,d,e,k,l;-1===a.search(/^[a-zA-Z0-9=+\/]+$/)&&n("Invalid character in base-64 string");f=a.indexOf("=");a=a.replace(/\=/g,"");-1!==f&&f<a.length&&n("Invalid '=' found in base-64 string");for(d=0;d<a.length;d+=4){l=a.substr(d,4);for(e=k=0;e<l.length;e+=1)f="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".indexOf(l[e]),k|=f<<18-6*e;for(e=0;e<l.length-1;e+=1)b[c>>2]|=(k>>>16-8*e&255)<<24-8*(c%4),c+=1}return{value:b,binLen:8*c}}
    function D(a,b){var c="",f=4*a.length,d,e;for(d=0;d<f;d+=1)e=a[d>>>2]>>>8*(3-d%4),c+="0123456789abcdef".charAt(e>>>4&15)+"0123456789abcdef".charAt(e&15);return b.outputUpper?c.toUpperCase():c}
    function E(a,b){var c="",f=4*a.length,d,e,k;for(d=0;d<f;d+=3){k=(a[d>>>2]>>>8*(3-d%4)&255)<<16|(a[d+1>>>2]>>>8*(3-(d+1)%4)&255)<<8|a[d+2>>>2]>>>8*(3-(d+2)%4)&255;for(e=0;4>e;e+=1)c=8*d+6*e<=32*a.length?c+"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt(k>>>6*(3-e)&63):c+b.b64Pad}return c}
    function F(a){var b={outputUpper:!1,b64Pad:"="};try{a.hasOwnProperty("outputUpper")&&(b.outputUpper=a.outputUpper),a.hasOwnProperty("b64Pad")&&(b.b64Pad=a.b64Pad)}catch(c){}"boolean"!==typeof b.outputUpper&&n("Invalid outputUpper formatting option");"string"!==typeof b.b64Pad&&n("Invalid b64Pad formatting option");return b}function G(a,b){return a>>>b|a<<32-b}function H(a,b,c){return a&b^~a&c}function S(a,b,c){return a&b^a&c^b&c}function T(a){return G(a,2)^G(a,13)^G(a,22)}
    function U(a){return G(a,6)^G(a,11)^G(a,25)}function V(a){return G(a,7)^G(a,18)^a>>>3}function W(a){return G(a,17)^G(a,19)^a>>>10}function X(a,b){var c=(a&65535)+(b&65535);return((a>>>16)+(b>>>16)+(c>>>16)&65535)<<16|c&65535}function Y(a,b,c,f){var d=(a&65535)+(b&65535)+(c&65535)+(f&65535);return((a>>>16)+(b>>>16)+(c>>>16)+(f>>>16)+(d>>>16)&65535)<<16|d&65535}
    function Z(a,b,c,f,d){var e=(a&65535)+(b&65535)+(c&65535)+(f&65535)+(d&65535);return((a>>>16)+(b>>>16)+(c>>>16)+(f>>>16)+(d>>>16)+(e>>>16)&65535)<<16|e&65535}
    function $(a,b,c){var f,d,e,k,l,j,z,B,I,g,J,u,h,m,s,p,x,y,q,K,L,M,N,O,P,Q,v=[],R,C;"SHA-224"===c||"SHA-256"===c?(J=64,m=16,s=1,P=Number,p=X,x=Y,y=Z,q=V,K=W,L=T,M=U,O=S,N=H,Q=[1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,
        338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298],g="SHA-224"===c?[3238371032,914150663,812702999,4144912697,4290775857,1750603025,1694076839,3204075428]:[1779033703,3144134277,1013904242,2773480762,
        1359893119,2600822924,528734635,1541459225]):n("Unexpected error in SHA-2 implementation");a[b>>>5]|=128<<24-b%32;a[(b+65>>>9<<4)+15]=b;R=a.length;for(u=0;u<R;u+=m){b=g[0];f=g[1];d=g[2];e=g[3];k=g[4];l=g[5];j=g[6];z=g[7];for(h=0;h<J;h+=1)v[h]=16>h?new P(a[h*s+u],a[h*s+u+1]):x(K(v[h-2]),v[h-7],q(v[h-15]),v[h-16]),B=y(z,M(k),N(k,l,j),Q[h],v[h]),I=p(L(b),O(b,f,d)),z=j,j=l,l=k,k=p(e,B),e=d,d=f,f=b,b=p(B,I);g[0]=p(b,g[0]);g[1]=p(f,g[1]);g[2]=p(d,g[2]);g[3]=p(e,g[3]);g[4]=p(k,g[4]);g[5]=p(l,g[5]);g[6]=
        p(j,g[6]);g[7]=p(z,g[7])}"SHA-224"===c?C=[g[0],g[1],g[2],g[3],g[4],g[5],g[6]]:"SHA-256"===c?C=g:n("Unexpected error in SHA-2 implementation");return C}
    window.jsSHA=function(a,b,c){var f=r,d=r,e=0,k=[0],l=0,j=r,l="undefined"!==typeof c?c:8;8===l||16===l||n("charSize must be 8 or 16");"HEX"===b?(0!==a.length%2&&n("srcString of HEX type must be in byte increments"),j=w(a),e=j.binLen,k=j.value):"ASCII"===b||"TEXT"===b?(j=t(a,l),e=j.binLen,k=j.value):"B64"===b?(j=A(a),e=j.binLen,k=j.value):n("inputFormat must be HEX, TEXT, ASCII, or B64");this.getHash=function(a,b,c){var g=r,l=k.slice(),j="";switch(b){case "HEX":g=D;break;case "B64":g=E;break;default:n("format must be HEX or B64")}"SHA-224"===
        a?(r===f&&(f=$(l,e,a)),j=g(f,F(c))):"SHA-256"===a?(r===d&&(d=$(l,e,a)),j=g(d,F(c))):n("Chosen SHA variant is not supported");return j};this.getHMAC=function(a,b,c,d,f){var j,h,m,s,p,x=[],y=[],q=r;switch(d){case "HEX":j=D;break;case "B64":j=E;break;default:n("outputFormat must be HEX or B64")}"SHA-224"===c?(m=64,p=224):"SHA-256"===c?(m=64,p=256):n("Chosen SHA variant is not supported");"HEX"===b?(q=w(a),s=q.binLen,h=q.value):"ASCII"===b||"TEXT"===b?(q=t(a,l),s=q.binLen,h=q.value):"B64"===b?(q=A(a),
        s=q.binLen,h=q.value):n("inputFormat must be HEX, TEXT, ASCII, or B64");a=8*m;b=m/4-1;m<s/8?(h=$(h,s,c),h[b]&=4294967040):m>s/8&&(h[b]&=4294967040);for(m=0;m<=b;m+=1)x[m]=h[m]^909522486,y[m]=h[m]^1549556828;c=$(y.concat($(x.concat(k),a+e,c)),a+p,c);return j(c,F(f))}};})();