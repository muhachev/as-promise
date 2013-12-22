package imukh.async{

  final internal class PromiseBase implements Promise{
    
    private var defer:Deferred;
    private var cancellable:Boolean;
    
    public function PromiseBase(defer:Deferred,cancellable:Boolean){
      this.defer=defer;
      this.cancellable=cancellable;
    }
    
    public function then(done:Function=null,fail:Function=null):Promise{
      defer.then(done,fail);
      return this;
    }
    
    public function done(func:Function):Promise{
      defer.done(func);
      return this;
    }

    public function fail(func:Function):Promise{
      defer.fail(func);
      return this;
    }
    
    public function cancel():Boolean{
      return cancellable&&defer.cancel();
    }
    
  }
}