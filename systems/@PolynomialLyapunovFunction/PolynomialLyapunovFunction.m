classdef PolynomialLyapunovFunction < LyapunovFunction
  
  properties
    p_t;
  end
  
  methods
    function obj=PolynomialLyapunovFunction(frame,time_invariant)
      obj=obj@LyapunovFunction(frame,time_invariant);
      obj.p_t = msspoly('t',1);
    end
    
    function V = eval(obj,t,x)
      V = double(subs(obj.getPoly,[obj.p_t;obj.getFrame.poly],[t;x]));
    end
    
%    function display(obj)
%      display(obj.getPoly(0));
%    end
    
    function Vpoly = getPoly(obj,t)
      error('polynomial lyapunov functions must implement getPoly');
    end
    
    function pVpt = getPolyTimeDeriv(obj,t)
      % returns only \partial{V} / \partial{t}
      error('not implemented yet');
    end
    
    function y = getLevelSet(obj,t,options)
      if (nargin<3) options=struct(); end
      if isTI(obj) t=0; elseif nargin<2 || isempty(t), error('you must specify a time'); end
      y = getLevelSet(obj.getFrame.poly,obj.getPoly(t),options);
    end
    
    function v = getLevelSetVolume(obj,t)
      if isTI(obj) t=0; elseif nargin<2 || isempty(t), error('you must specify a time'); end
      v = getLevelSetVolume(obj.getFrame.poly,obj.getPoly(t));
    end
    
    function V = inFrame(obj,frame)
      if (frame==obj.getFrame)
        V = obj;
      else
        tf = findTransform(frame,obj.getFrame,true);
        if ~isTI(obj) || ~isTI(tf),  error('not implemented yet'); end
        Vpoly = subss(obj.getPoly,obj.getFrame.poly,tf.output(0,[],frame.poly));
        V = SpotPolynomialLyapunovFunction(frame,Vpoly);
      end
    end
    
    function V = extractQuadraticLyapunovFunction(obj)
      if (~isTI(obj)) error('not implemented yet'); end

      Vpoly = obj.getPoly();
      x = obj.getFrame.poly;
      
      if (deg(Vpoly,x)>2) error('not quadratic'); end
      
      S=double(.5*subs(diff(diff(Vpoly,x)',x),x,0*x));
      s1=double(subs(diff(Vpoly,x),x,0*x))';
      s2=double(subs(Vpoly,x,0*x));
      
      V = QuadraticLyapunovFunction(obj.getFrame,S,s1,s2);
    end
    
    function V = mtimes(a,b)
      % support simple scaling of Lyapunov functions via multiplication by
      % a (scalar) double
      error('not implemented yet'); % derived classes should implement this method
    end

    
    % since I only care about scalar multiplication / division, i can
    % support the related calls, too.
    function V = times(a,b)
      sizecheck(a,1); sizecheck(b,1);
      V = mtimes(a,b); 
    end
    function V = mrdivide(a,b)
      sizecheck(a,1); sizecheck(b,1);
      V = mtimes(a,inv(b));
    end
    function mldivide(a,b)
      sizecheck(a,1); sizecheck(b,1);
      V = mtimes(inv(a),b);
    end
    function rdivide(a,b)
      sizecheck(a,1); sizecheck(b,1);
      V = mtimes(a,inv(b));
    end
    function ldivide(a,b)
      sizecheck(a,1); sizecheck(b,1);
      V = mtimes(inv(a),b);
    end
  end

end
