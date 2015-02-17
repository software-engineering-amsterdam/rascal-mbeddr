module util::SimpleBox

data Box
  = h(list[Box] xs, int hs)
  | v(list[Box] xs, int vs)
  | i(list[Box] xs, int vs, int is)
  | l(value x)
  ;
  
Box H(Box xs..., int hs = 0) = h(xs, hs);
Box V(Box xs..., int vs = 1) = v(xs, vs);
Box I(Box xs..., int vs = 1, int is = 2) = i(xs, vs, is);
Box L(value x) = l(x);

str format(Box b) {
  str out = "";
  void write(str x) {
    out += x;
  }
  eval(b, 0, false, write);
  return out;
}

void eval(h(bs, hs), int ind, bool vert, void(str) write) {
  if (vert) {
    write(spaces(ind));
  }
  first = true;
  for (b <- bs) {
    if (!first) {
      write(spaces(hs));
    }
    eval(b, ind, false, write);
    first = false;
  }
}

void eval(v(bs, vs), int ind, bool vert, void(str) write) {
  first = true;
  for (b <- bs) {
    if (!first) {
      write(newlines(vs));
    }
    eval(b, ind, true, write);
    first = false;
  }
}

void eval(i(bs, vs, \is), int ind, bool vert, void(str) write) 
  = eval(v(bs, vs), ind + \is, true, write);

void eval(l(value x), int ind, bool vert, void(str) write) {
  if (vert) {
    write(spaces(ind));
  }
  write("<x>");
}


str spaces(int n) = ( "" | it + " " | int i <- [0..n] ); 
str newlines(int n) = ( "" | it + "\n" | int i <- [0..n] ); 

