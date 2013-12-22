package imukh.async{
  public interface Promise{
    function then(done:Function=null,fail:Function=null):Promise;
    function done(func:Function):Promise;
    function fail(func:Function):Promise;
    function cancel():Boolean;
  }
}