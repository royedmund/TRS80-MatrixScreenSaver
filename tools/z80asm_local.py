import re,struct,sys
REG={'B':0,'C':1,'D':2,'E':3,'H':4,'L':5,'(HL)':6,'A':7}
RR={'BC':0x01,'DE':0x11,'HL':0x21,'SP':0x31}
CCJP={'NZ':0xC2,'Z':0xCA,'NC':0xD2,'C':0xDA,'PO':0xE2,'PE':0xEA,'P':0xF2,'M':0xFA}
CCJR={'NZ':0x20,'Z':0x28,'NC':0x30,'C':0x38}

def atom(s,syms):
 s=s.strip(); sl=s.lower();
 if s in syms:return syms[s]
 if re.fullmatch(r'[0-9a-f]+h',sl):return int(sl[:-1],16)
 if sl.startswith('0x'):return int(sl[2:],16)
 if re.fullmatch(r'[0-9]+',sl):return int(sl)
 if sl.startswith("x'"):return int(sl[2:-1],16)
 if s in syms:return syms[s]
 if '+' in s: a,b=s.split('+',1);return atom(a,syms)+atom(b,syms)
 if '-' in s: a,b=s.split('-',1);return atom(a,syms)-atom(b,syms)
 return 0

def assemble(src,origin=0x6000):
 lines=[]; symbols={};pc=origin
 for raw in src.splitlines():
  raw=raw.split(';')[0].strip()
  if not raw:continue
  m=re.match(r'^([A-Za-z_][\w]*):\s*(.*)$',raw)
  if m:
   sym,raw=m.groups();symbols[sym]=pc
  if not raw:continue
  op,_,args=raw.partition(' ');op=op.upper();args=args.strip()
  lines.append((pc,op,args));size=len(encode(op,args,{},pc));pc+=size
 binary=bytearray();pc=origin
 for p,op,args in lines:
  out=encode(op,args,symbols,p)
  if op=='ORG':continue
  binary.extend(out);pc=p+len(out)
 return bytes(binary),symbols

def encode(op,args,s,pc):
 v=lambda x:atom(x,s)
 word=lambda x:list(struct.pack('<H',v(x)&65535))
 b=lambda x:v(x)&255
 pair=[a.strip().upper() for a in args.split(',')]
 if op in ('ORG','END'):return []
 if op=='DB':return [b(x) for x in pair]
 if op=='DW':return sum((word(x) for x in pair),[])
 if op=='DS':return [0]*v(args)
 if op=='NOP':return [0]
 if op=='RET':return [0xC9]
 if op=='LDIR':return [0xED,0xB0]
 if op=='RRCA':return [0x0F]
 if op=='CALL':return [0xCD]+word(args)
 if op=='JP':
  if len(pair)==1:return [0xC3]+word(pair[0]);
  return [CCJP[pair[0]]]+word(pair[1])
 if op in ('JR','DJNZ'):
  dest=pair[-1]; d=v(dest)-(pc+(2));
  if s and not -128<=d<=127:raise ValueError(f'JR/DJNZ too far at {pc:04X}: {dest} {d}')
  if op=='DJNZ':return [0x10,d&255]
  return [CCJR.get(pair[0],0x18),d&255]
 if op=='LD':
  x,y=pair
  if x in ('IX','IY'):
   return [0xDD if x=='IX' else 0xFD,0x21]+word(y)
  if x in RR and y not in REG and not y.startswith('('):return [RR[x]]+word(y)
  if x=='HL' and y.startswith('(') and y!='(HL)':return [0x2A]+word(y[1:-1])
  if x.startswith('(') and x!='(HL)' and y=='HL':return [0x22]+word(x[1:-1])
  if x=='A' and y.startswith('(') and y!='(HL)' and not y.startswith('(IX') and not y.startswith('(IY'):return [0x3A]+word(y[1:-1])
  if x.startswith('(') and x!='(HL)' and y=='A' and not x.startswith('(IX') and not x.startswith('(IY'):return [0x32]+word(x[1:-1])
  if x in REG and y in REG:return [0x40 + REG[x]*8 + REG[y]]
  m=re.match(r'^\((IX|IY)([+-]\d+)\)$',x)
  if m:
   prefix=0xDD if m[1]=='IX' else 0xFD;disp=int(m[2])&255
   if y in REG:return [prefix,0x70+REG[y],disp]
   return [prefix,0x36,disp,b(y)]
  m=re.match(r'^\((IX|IY)([+-]\d+)\)$',y)
  if m:
   prefix=0xDD if m[1]=='IX' else 0xFD;disp=int(m[2])&255
   if x in REG:return [prefix,0x46+REG[x]*8,disp]
  if x in REG:
   return [0x06+REG[x]*8,b(y)]
  raise ValueError('LD '+args)
 if op in ('INC','DEC'):
  t=pair[0]
  if t in ('IX','IY'):return [0xDD if t=='IX' else 0xFD,0x23 if op=='INC' else 0x2B]
  if t in RR:return [(0x03 if op=='INC' else 0x0B) + (RR[t]-1)]
  if t in REG:return [(0x04 if op=='INC' else 0x05) + REG[t]*8]
 if op in ('AND','OR','XOR','CP','SUB','ADD'):
  x=pair[-1];
  if op=='ADD' and len(pair)==2 and pair[0]=='A':pass
  if x in REG:
   return [{'AND':0xA0,'OR':0xB0,'XOR':0xA8,'CP':0xB8,'SUB':0x90,'ADD':0x80}[op]+REG[x]]
  m=re.match(r'^\((IX|IY)([+-]\d+)\)$',x)
  if m:
   return [0xDD if m[1]=='IX' else 0xFD,{'AND':0xA6,'OR':0xB6,'XOR':0xAE,'CP':0xBE,'SUB':0x96,'ADD':0x86}[op],int(m[2])&255]
  return [{'AND':0xE6,'OR':0xF6,'XOR':0xEE,'CP':0xFE,'SUB':0xD6,'ADD':0xC6}[op],b(x)]
 if op=='BIT':return [0xCB,0x40+v(pair[0])*8+REG[pair[1]]]
 if op in ('SRL','RR'):
  return [0xCB,{'SRL':0x38,'RR':0x18}[op]+REG[pair[0]]]
 raise ValueError(f'unknown {op} {args} at {pc:04x}')

def cmd(data,org=0x6000):
 out=bytearray()
 for offset in range(0,len(data),254):
  chunk=data[offset:offset+254];out.extend([1,(len(chunk)+2)&255]);out+=struct.pack('<H',org+offset);out+=chunk
 out.extend([2,2,org&255,org>>8]);return bytes(out)

if __name__=='__main__':
 import pathlib
 src=pathlib.Path(sys.argv[1]).read_text();d,syms=assemble(src)
 print('binary length',len(d),'symbols',syms)
 pathlib.Path(sys.argv[2]).write_bytes(cmd(d))
