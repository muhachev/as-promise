package imukh.async{

  final public class Deferred{
    
    private static const STATE_INITIAL:int=0;
    private static const STATE_RESOLVED:int=1;
    private static const STATE_REJECTED:int=2;
    private static const STATE_CANCEL:int=3;

    private var state:int=STATE_INITIAL;
    
    [ArrayElementType("Function")]
    private const resolvers:Array=[];
    
    [ArrayElementType("Function")]
    private const rejecters:Array=[];
    
    private var data:Array;
    
    public function Deferred(exec:Function){
      exec(this);
    }
    
    public function get cancelled():Boolean{
      return state==STATE_CANCEL;
    }
    
    public function resolve(...data):void{
      if(state!=STATE_INITIAL)return;
      state=STATE_RESOLVED;
      this.data=data;
      while(resolvers.length)resolvers.shift().apply(null,data);  
      rejecters.length=0;
      _cancelHandler=null;
    }
    
    public function reject(...data):void{
      if(state!=STATE_INITIAL)return;
      state=STATE_REJECTED;
      this.data=data;
      while(rejecters.length)rejecters.shift().apply(null,data);  
      resolvers.length=0;
      _cancelHandler=null;
    }
    
    public function done(func:Function):Deferred{
      if(func==null)return this;
      switch(state){
        case STATE_INITIAL:
          resolvers.push(func);    
          break;
        case STATE_RESOLVED:
          func.apply(null,data);  
          break;
      }
      return this;
    }
    
    public function fail(func:Function):Deferred{
      if(func==null)return this;
      switch(state){
        case STATE_INITIAL:
          rejecters.push(func);    
          break;
        case STATE_REJECTED:
          func.apply(null,data);
          break;
      }
      return this;
    }
    
    public function then(done:Function=null,fail:Function=null):Deferred{
      this.done(done);
      this.fail(fail);
      return this;
    }
    
    public function promise(cancellable:Boolean=false):Promise{
      return new PromiseBase(this,cancellable);
    }
    
    private var _cancelHandler:Function;
    
    public function set cancelHandler(handler:Function):void{
      _cancelHandler=handler;
    }
    
    public function cancel():Boolean{
      if(state!=STATE_INITIAL)return false;
      state=STATE_CANCEL;
      resolvers.length=0;
      rejecters.length=0;
      data=null;
      _cancelHandler&&_cancelHandler();
      _cancelHandler=null;
      return true;
    }
    
    public static function when(...promises):Promise{
      return new Deferred(exec).promise(true);
      function exec(defer:Deferred):void{
        var rets:Array=[],failed:Boolean=false;
        var count:uint=promises.length;
        for(var i:uint=0;i<promises.length;i++){
          !function(i:uint):void{
            var promise:Promise=promises[i];
            promise.then(done,fail);
            function done(...args):void{
              if(failed||defer.cancelled)return;
              var arg:*;
              if(!args.length)arg=null;
              else if(args.length==1)arg=args[0];
              else arg=args;
              rets[i]=arg;
              !--count&&defer.resolve.apply(null,rets);
            }
            function fail(...args):void{
              if(failed||defer.cancelled)return;
              failed=true;
              defer.reject.apply(null,args);
            }
          }(i);
        }
      }
    }
    
  }
}